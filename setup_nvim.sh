#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$CONFIG_HOME/nvim"
BIN_DIR="$HOME/.local/bin"
NPM_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/npm"
NVIM_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-stable"
NODE_BIN_DIR=""
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

export PATH="$BIN_DIR:$NPM_PREFIX/bin:$HOME/go/bin:$PATH"

log() {
  printf '[nvim-config] %s\n' "$*"
}

warn() {
  printf '[nvim-config] warning: %s\n' "$*" >&2
}

die() {
  printf '[nvim-config] error: %s\n' "$*" >&2
  exit 1
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif has_command sudo; then
    sudo "$@"
  else
    die "sudo is required to install Ubuntu packages"
  fi
}

version_at_least_0113() {
  local version="${1#v}"
  local major="${version%%.*}"
  local remainder="${version#*.}"
  local minor="${remainder%%.*}"
  local patch="${remainder#*.}"
  patch="${patch%%.*}"

  [[ "$major" -gt 0 || ( "$major" -eq 0 && "$minor" -gt 11 ) || ( "$major" -eq 0 && "$minor" -eq 11 && "$patch" -ge 3 ) ]]
}

nvim_version() {
  "${1:-nvim}" --version | sed -n '1s/^NVIM v//p'
}

add_shell_path() {
  local profile="$1"
  local marker="# >>> vim-config nvim paths >>>"
  local end_marker="# <<< vim-config nvim paths <<<"
  local path_line="export PATH=\"$BIN_DIR:$NPM_PREFIX/bin:$HOME/go/bin:\$PATH\""
  local node_marker="# >>> vim-config node path >>>"
  local node_end_marker="# <<< vim-config node path <<<"
  local node_path_line="export PATH=\"$NODE_BIN_DIR:\$PATH\""

  touch "$profile"
  if ! grep -Fq "$marker" "$profile"; then
    printf '\n%s\n%s\n%s\n' "$marker" "$path_line" "$end_marker" >> "$profile"
  fi
  if [[ -n "$NODE_BIN_DIR" ]] && ! grep -Fqx "$node_path_line" "$profile"; then
    printf '\n%s\n%s\n%s\n' "$node_marker" "$node_path_line" "$node_end_marker" >> "$profile"
  fi
}

configure_shell_path() {
  case "${SHELL:-}" in
    */zsh)
      add_shell_path "$HOME/.zprofile"
      add_shell_path "$HOME/.zshrc"
      ;;
    */bash)
      add_shell_path "$HOME/.profile"
      add_shell_path "$HOME/.bashrc"
      ;;
    *)
      add_shell_path "$HOME/.profile"
      ;;
  esac
}

ensure_homebrew() {
  if has_command brew; then
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    return
  fi
  if [[ -x /usr/local/bin/brew ]]; then
    export PATH="/usr/local/bin:$PATH"
    return
  fi

  has_command curl || die "curl is required to install Homebrew"
  log "Homebrew is not installed; installing it"
  local installer="$TMP_DIR/homebrew-install.sh"
  curl --fail --location --silent --show-error \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
    --output "$installer"
  NONINTERACTIVE=1 /bin/bash "$installer"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -x /usr/local/bin/brew ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
  has_command brew || die "Homebrew installation did not provide brew"
}

install_macos_packages() {
  ensure_homebrew
  log "Installing macOS packages with Homebrew"
  brew install neovim git ripgrep fd python node go gopls uv shfmt
  prefer_homebrew_node
}

install_ubuntu_packages() {
  has_command apt-get || die "This script supports Ubuntu Linux, which must provide apt-get"
  log "Installing Ubuntu packages"
  as_root apt-get update
  as_root apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    git \
    golang-go \
    gzip \
    nodejs \
    npm \
    python3 \
    python3-venv \
    ripgrep \
    shfmt \
    wl-clipboard \
    xclip

  if apt-cache show gopls >/dev/null 2>&1; then
    as_root apt-get install -y gopls
  fi
}

install_linux_nvim() {
  local architecture
  case "$(uname -m)" in
    x86_64|amd64) architecture="x86_64" ;;
    aarch64|arm64) architecture="arm64" ;;
    *) die "Unsupported Linux architecture: $(uname -m)" ;;
  esac

  local archive="$TMP_DIR/nvim-linux-${architecture}.tar.gz"
  local extracted="$TMP_DIR/nvim-linux-${architecture}"
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${architecture}.tar.gz"

  log "Installing the latest stable Neovim archive"
  curl --fail --location --silent --show-error --retry 3 "$url" --output "$archive"
  tar -xzf "$archive" -C "$TMP_DIR"
  [[ -x "$extracted/bin/nvim" ]] || die "Neovim archive did not contain an executable"

  mkdir -p "$(dirname "$NVIM_PREFIX")"
  if [[ -e "$NVIM_PREFIX" || -L "$NVIM_PREFIX" ]]; then
    mv "$NVIM_PREFIX" "$NVIM_PREFIX.backup.$(date +%Y%m%d%H%M%S)"
  fi
  mv "$extracted" "$NVIM_PREFIX"

  if [[ -e "$BIN_DIR/nvim" || -L "$BIN_DIR/nvim" ]]; then
    if [[ -L "$BIN_DIR/nvim" && "$(readlink "$BIN_DIR/nvim")" == "$NVIM_PREFIX/bin/nvim" ]]; then
      return
    fi
    mv "$BIN_DIR/nvim" "$BIN_DIR/nvim.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$NVIM_PREFIX/bin/nvim" "$BIN_DIR/nvim"
}

ensure_neovim() {
  if has_command nvim && version_at_least_0113 "$(nvim_version)"; then
    log "Using Neovim $(nvim_version)"
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew upgrade neovim || true
    has_command nvim || brew install neovim
    version_at_least_0113 "$(nvim_version)" || die "Homebrew provided a Neovim version older than 0.11.3"
  else
    install_linux_nvim
    version_at_least_0113 "$(nvim_version)" || die "Downloaded Neovim is older than 0.11.3"
  fi
  log "Using Neovim $(nvim_version)"
}

ensure_uv() {
  if has_command uv; then
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install uv
  else
    log "Installing uv"
    local installer="$TMP_DIR/uv-install.sh"
    curl --fail --location --silent --show-error https://astral.sh/uv/install.sh --output "$installer"
    UV_NO_MODIFY_PATH=1 sh "$installer"
    export PATH="$BIN_DIR:$PATH"
  fi
  has_command uv || die "uv installation did not provide the uv command"
}

prefer_homebrew_node() {
  local node_prefix
  node_prefix="$(brew --prefix node 2>/dev/null || true)"
  if [[ -x "$node_prefix/bin/node" && -x "$node_prefix/bin/npm" ]]; then
    NODE_BIN_DIR="$node_prefix/bin"
    # A versioned Homebrew Node formula can appear earlier in PATH and may be
    # unusable after one of its shared-library dependencies is upgraded.
    export PATH="$node_prefix/bin:$PATH"
  fi
}

install_python_tools() {
  log "Installing Python tools with uv"
  uv tool install --upgrade ty
  uv tool install --upgrade ruff
}

install_node_tools() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    prefer_homebrew_node
  fi

  if ! has_command node || ! node --version >/dev/null 2>&1 || ! has_command npm || ! npm --version >/dev/null 2>&1; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      log "The Homebrew Node installation is not runnable; reinstalling it"
      brew reinstall node
      prefer_homebrew_node
    fi
  fi

  node --version >/dev/null 2>&1 \
    || die "Node is installed but cannot run; repair Node before rerunning setup"
  npm --version >/dev/null 2>&1 \
    || die "npm is installed but cannot run; repair npm before rerunning setup"

  mkdir -p "$NPM_PREFIX"
  npm config set prefix "$NPM_PREFIX"
  log "Installing JavaScript and TypeScript tools with npm ($(node --version), npm $(npm --version))"
  npm install --global \
    eslint \
    eslint_d \
    prettier \
    typescript \
    typescript-language-server
}

install_gopls() {
  if has_command gopls; then
    return
  fi
  has_command go || return
  log "Installing gopls"
  if ! GOBIN="$BIN_DIR" go install golang.org/x/tools/gopls@latest; then
    warn "Could not install gopls; Go support will remain disabled until it is installed"
  fi
}

taplo_is_ready() {
  has_command taplo \
    && taplo lsp --help >/dev/null 2>&1 \
    && taplo fmt --help >/dev/null 2>&1
}

install_taplo() {
  local platform
  local architecture
  case "$(uname -s)" in
    Darwin) platform="darwin" ;;
    Linux) platform="linux" ;;
    *) die "Unsupported operating system for Taplo: $(uname -s)" ;;
  esac
  case "$(uname -m)" in
    x86_64|amd64) architecture="x86_64" ;;
    aarch64|arm64) architecture="aarch64" ;;
    *) die "Unsupported architecture for Taplo: $(uname -m)" ;;
  esac

  local archive="$TMP_DIR/taplo-${platform}-${architecture}.gz"
  local binary="$BIN_DIR/taplo.new"
  local url="https://github.com/tamasfe/taplo/releases/latest/download/taplo-${platform}-${architecture}.gz"
  log "Installing Taplo with TOML language-server support"
  curl --fail --location --silent --show-error --retry 3 "$url" --output "$archive"
  gzip -cd "$archive" > "$binary"
  chmod 755 "$binary"
  mv "$binary" "$BIN_DIR/taplo"
}

ensure_taplo() {
  if taplo_is_ready; then
    return
  fi
  install_taplo
  taplo_is_ready || die "Taplo does not provide both 'lsp' and 'fmt' commands"
}

ensure_fd_alias() {
  if has_command fd || ! has_command fdfind; then
    return
  fi
  if [[ ! -e "$BIN_DIR/fd" && ! -L "$BIN_DIR/fd" ]]; then
    ln -s "$(command -v fdfind)" "$BIN_DIR/fd"
  fi
}

link_config() {
  mkdir -p "$CONFIG_HOME" "$BIN_DIR"
  if [[ -L "$CONFIG_DIR" && "$(readlink "$CONFIG_DIR")" == "$REPO_DIR/nvim" ]]; then
    return
  fi

  if [[ -e "$CONFIG_DIR" || -L "$CONFIG_DIR" ]]; then
    local backup="$CONFIG_DIR.backup.$(date +%Y%m%d%H%M%S)"
    log "Moving existing Neovim configuration to $backup"
    mv "$CONFIG_DIR" "$backup"
  fi
  ln -s "$REPO_DIR/nvim" "$CONFIG_DIR"
}

install_plugins() {
  log "Installing the locked Neovim plugins"
  nvim --headless "+Lazy! restore" +qa
  nvim --headless +qa
}

main() {
  [[ "$(uname -s)" == "Darwin" || "$(uname -s)" == "Linux" ]] \
    || die "Only macOS and Linux are supported"

  mkdir -p "$BIN_DIR"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    install_macos_packages
  else
    install_ubuntu_packages
  fi

  configure_shell_path

  ensure_neovim
  ensure_uv
  install_python_tools
  install_node_tools
  install_gopls
  ensure_taplo
  ensure_fd_alias
  link_config
  install_plugins

  log "Neovim setup is complete"
  log "Open a new shell before using user-local commands installed under $BIN_DIR"
}

main "$@"
