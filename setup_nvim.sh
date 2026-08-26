#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$CONFIG_HOME/nvim"
BIN_DIR="$HOME/.local/bin"
NPM_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/npm"
NVIM_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-stable"
LAZY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
LAZY_LOCKFILE="$REPO_DIR/nvim/lazy-lock.json"
LAZY_URL="https://github.com/folke/lazy.nvim.git"
NODE_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/node-v24"
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

lazy_commit_from_lockfile() {
	awk '
		/"lazy\.nvim"[[:space:]]*:/ { found_lazy = 1 }
		found_lazy && /"commit"[[:space:]]*:/ {
			line = $0
			sub(/^.*"commit"[[:space:]]*:[[:space:]]*"/, "", line)
			sub(/".*$/, "", line)
			print line
			exit
		}
	' "$LAZY_LOCKFILE"
}

backup_lazy_checkout() {
	local backup
	backup="$(mktemp -d "${LAZY_PATH}.backup.XXXXXX")"
	rmdir "$backup"
	mv "$LAZY_PATH" "$backup"
	log "Moved the existing lazy.nvim checkout to $backup"
}

clone_lazy() {
	log "Cloning lazy.nvim metadata"
	if ! git clone --filter=blob:none --no-checkout --no-tags "$LAZY_URL" "$LAZY_PATH"; then
		die "Could not clone lazy.nvim from $LAZY_URL"
	fi
}

fetch_lazy_commit() {
	local lazy_commit="$1"

	if git -C "$LAZY_PATH" cat-file -e "${lazy_commit}^{commit}" >/dev/null 2>&1; then
		return
	fi

	log "Fetching the locked lazy.nvim commit"
	if ! git -C "$LAZY_PATH" fetch --filter=blob:none --no-tags "$LAZY_URL" "$lazy_commit"; then
		die "Could not fetch lazy.nvim commit $lazy_commit"
	fi
	git -C "$LAZY_PATH" cat-file -e "${lazy_commit}^{commit}" >/dev/null 2>&1 ||
		die "The lazy.nvim repository does not contain locked commit $lazy_commit"
}

lazy_checkout_ready() {
	local lazy_commit="$1"
	local current_commit
	local checkout_status

	current_commit="$(git -C "$LAZY_PATH" rev-parse --verify HEAD 2>/dev/null)" || return 1
	[[ "$current_commit" == "$lazy_commit" ]] || return 1
	[[ -f "$LAZY_PATH/lua/lazy/init.lua" ]] || return 1
	checkout_status="$(git -C "$LAZY_PATH" status --porcelain --untracked-files=all 2>/dev/null)" || return 1
	[[ -z "$checkout_status" ]]
}

ensure_lazy() {
	local lazy_commit
	lazy_commit="$(lazy_commit_from_lockfile)"
	[[ "$lazy_commit" =~ ^[0-9a-f]{40}$ ]] ||
		die "Could not read a valid lazy.nvim commit from $LAZY_LOCKFILE"

	mkdir -p "$(dirname "$LAZY_PATH")"
	if ! git -C "$LAZY_PATH" rev-parse --git-dir >/dev/null 2>&1; then
		if [[ -e "$LAZY_PATH" || -L "$LAZY_PATH" ]]; then
			backup_lazy_checkout
		fi
		clone_lazy
	fi

	fetch_lazy_commit "$lazy_commit"
	if lazy_checkout_ready "$lazy_commit"; then
		log "Using locked lazy.nvim commit ${lazy_commit:0:12}"
		return
	fi

	if git -C "$LAZY_PATH" -c advice.detachedHead=false checkout --quiet --detach "$lazy_commit" &&
		lazy_checkout_ready "$lazy_commit"; then
		log "Using locked lazy.nvim commit ${lazy_commit:0:12}"
		return
	fi

	# A manually modified checkout should not be overwritten. Preserve it and
	# create a clean pinned copy so setup remains unattended and recoverable.
	backup_lazy_checkout
	clone_lazy
	fetch_lazy_commit "$lazy_commit"
	git -C "$LAZY_PATH" -c advice.detachedHead=false checkout --quiet --detach "$lazy_commit" ||
		die "Could not check out locked lazy.nvim commit $lazy_commit"
	lazy_checkout_ready "$lazy_commit" ||
		die "The lazy.nvim checkout is not a clean copy of locked commit $lazy_commit"
	log "Using locked lazy.nvim commit ${lazy_commit:0:12}"
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

version_at_least_0120() {
	local version="${1#v}"
	local major="${version%%.*}"
	local remainder="${version#*.}"
	local minor="${remainder%%.*}"
	local patch="${remainder#*.}"
	patch="${patch%%.*}"

	[[ "$major" -gt 0 || ("$major" -eq 0 && "$minor" -gt 12) || ("$major" -eq 0 && "$minor" -eq 12 && "$patch" -ge 0) ]]
}

version_at_least_0261() {
	local version="${1#v}"
	local major="${version%%.*}"
	local remainder="${version#*.}"
	local minor="${remainder%%.*}"
	local patch="${remainder#*.}"
	patch="${patch%%.*}"

	[[ "$major" -gt 0 || ("$major" -eq 0 && "$minor" -gt 26) || ("$major" -eq 0 && "$minor" -eq 26 && "$patch" -ge 1) ]]
}

nvim_version() {
	"${1:-nvim}" --version | sed -n '1s/^NVIM v//p'
}

update_shell_profile() {
	local profile="$1"
	local marker="# >>> vim-config additions >>>"
	local end_marker="# <<< vim-config additions <<<"
	local path_line="export PATH=\"$BIN_DIR:$NPM_PREFIX/bin:$HOME/go/bin:\$PATH\""
	local temp

	touch "$profile"
	temp="$(mktemp "$TMP_DIR/profile.XXXXXX")"
	# Remove blocks created by this script, including the two-block format used
	# by older versions, while preserving an incomplete block after interruption.
	awk '
		function is_start(line) {
			return line == "# >>> vim-config nvim paths >>>" ||
				line == "# >>> vim-config node path >>>" ||
				line == "# >>> vim-config additions >>>"
		}
		function is_end(line) {
			return line == "# <<< vim-config nvim paths <<<" ||
				line == "# <<< vim-config node path <<<" ||
				line == "# <<< vim-config additions <<<"
		}
		{
			if (!in_block) {
				if (is_start($0)) {
					in_block = 1
					block_count = 1
					block[block_count] = $0
					next
				}
				print
				next
			}

			block[++block_count] = $0
			if (is_end($0)) {
				in_block = 0
				block_count = 0
			}
		}
		END {
			if (in_block)
				for (i = 1; i <= block_count; i++)
					print block[i]
		}
	' "$profile" >"$temp"

	{
		printf '\n%s\n' "$marker"
		printf '%s\n' "$path_line"
		if [[ -n "$NODE_BIN_DIR" ]]; then
			printf 'export PATH="%s:$PATH"\n' "$NODE_BIN_DIR"
		fi
		printf '%s\n' \
			'export EDITOR=nvim' \
			'export VISUAL=nvim' \
			'export GIT_EDITOR=nvim' \
			'alias vim=nvim' \
			'alias vi=nvim'
		printf '%s\n' "$end_marker"
	} >>"$temp"
	cp "$temp" "$profile"
}

configure_shell_path() {
	case "${SHELL:-}" in
	*/zsh)
		update_shell_profile "$HOME/.zprofile"
		update_shell_profile "$HOME/.zshrc"
		;;
	*/bash)
		update_shell_profile "$HOME/.profile"
		update_shell_profile "$HOME/.bashrc"
		;;
	*)
		update_shell_profile "$HOME/.profile"
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
	brew install neovim git ripgrep fd python node@24 go gopls uv shfmt
	prefer_homebrew_node24
}

install_ubuntu_packages() {
	has_command apt-get || die "This script supports Ubuntu Linux, which must provide apt-get"
	log "Installing Ubuntu packages"
	if ! as_root dpkg --configure -a; then
		die "dpkg could not finish configuring packages; run 'sudo dpkg --configure -a', resolve the reported package error, and rerun this script"
	fi
	as_root apt-get update
	as_root apt-get install -y \
		build-essential \
		ca-certificates \
		curl \
		fd-find \
		git \
		golang-go \
		gzip \
		python3 \
		python3-venv \
		ripgrep \
		shfmt \
		unzip \
		xz-utils \
		wl-clipboard \
		xclip

	if apt-cache show gopls >/dev/null 2>&1; then
		as_root apt-get install -y gopls
	fi
}

node_is_24() {
	local version
	version="$(node --version 2>/dev/null || true)"
	[[ "$version" == v24.* ]]
}

node_is_ready() {
	node_is_24 && has_command npm && npm --version >/dev/null 2>&1
}

prefer_local_node() {
	if [[ -x "$NODE_PREFIX/bin/node" && -x "$NODE_PREFIX/bin/npm" ]]; then
		NODE_BIN_DIR="$NODE_PREFIX/bin"
		export PATH="$NODE_BIN_DIR:$PATH"
	fi
}

install_linux_node() {
	local architecture
	case "$(uname -m)" in
	x86_64 | amd64) architecture="x64" ;;
	aarch64 | arm64) architecture="arm64" ;;
	*) die "Unsupported Linux architecture for Node.js: $(uname -m)" ;;
	esac

	local base_url="https://nodejs.org/dist/latest-v24.x"
	local checksums="$TMP_DIR/node-v24-SHASUMS256.txt"
	local archive_name
	local checksum
	local archive
	local extracted

	log "Installing the latest Node.js 24 LTS archive"
	curl --fail --location --silent --show-error --retry 3 \
		"$base_url/SHASUMS256.txt" --output "$checksums"
	archive_name="$(awk -v architecture="$architecture" \
		'$2 ~ ("^node-v24\\.[0-9]+\\.[0-9]+-linux-" architecture "\\.tar\\.xz$") { print $2; exit }' \
		"$checksums")"
	checksum="$(awk -v archive_name="$archive_name" \
		'$2 == archive_name { print $1; exit }' "$checksums")"
	[[ -n "$archive_name" && -n "$checksum" ]] ||
		die "Could not find a Node.js 24 archive for Linux $(uname -m)"

	archive="$TMP_DIR/$archive_name"
	curl --fail --location --silent --show-error --retry 3 \
		"$base_url/$archive_name" --output "$archive"
	if ! printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status -; then
		die "Node.js archive checksum verification failed"
	fi

	extracted="${archive%.tar.xz}"
	tar -xJf "$archive" -C "$TMP_DIR"
	[[ -x "$extracted/bin/node" && -x "$extracted/bin/npm" ]] ||
		die "Node.js archive did not contain node and npm"

	mkdir -p "$(dirname "$NODE_PREFIX")"
	if [[ -e "$NODE_PREFIX" || -L "$NODE_PREFIX" ]]; then
		mv "$NODE_PREFIX" "$NODE_PREFIX.backup.$(date +%Y%m%d%H%M%S)"
	fi
	mv "$extracted" "$NODE_PREFIX"
	prefer_local_node
}

install_linux_nvim() {
	local architecture
	case "$(uname -m)" in
	x86_64 | amd64) architecture="x86_64" ;;
	aarch64 | arm64) architecture="arm64" ;;
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

tree_sitter_version() {
	tree-sitter --version 2>/dev/null |
		sed -n 's/.*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p'
}

tree_sitter_is_ready() {
	local version
	version="$(tree_sitter_version)"
	[[ -n "$version" ]] && version_at_least_0261 "$version"
}

install_tree_sitter_cli() {
	local platform
	local architecture
	case "$(uname -s)" in
	Darwin) platform="macos" ;;
	Linux) platform="linux" ;;
	*) die "Unsupported operating system for Tree-sitter: $(uname -s)" ;;
	esac
	case "$(uname -m)" in
	x86_64 | amd64) architecture="x64" ;;
	aarch64 | arm64) architecture="arm64" ;;
	*) die "Unsupported architecture for Tree-sitter: $(uname -m)" ;;
	esac

	local archive="$TMP_DIR/tree-sitter-cli-${platform}-${architecture}.zip"
	local binary="$BIN_DIR/tree-sitter.new"
	local url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-${platform}-${architecture}.zip"
	log "Installing the latest Tree-sitter CLI"
	curl --fail --location --silent --show-error --retry 3 "$url" --output "$archive"
	unzip -p "$archive" tree-sitter >"$binary"
	chmod 755 "$binary"
	mv "$binary" "$BIN_DIR/tree-sitter"
}

ensure_tree_sitter_cli() {
	if tree_sitter_is_ready; then
		return
	fi
	install_tree_sitter_cli
	tree_sitter_is_ready || die "Tree-sitter CLI 0.26.1 or newer is required for nvim-treesitter"
}

ensure_neovim() {
	if has_command nvim && version_at_least_0120 "$(nvim_version)"; then
		log "Using Neovim $(nvim_version)"
		return
	fi

	if [[ "$(uname -s)" == "Darwin" ]]; then
		brew upgrade neovim || true
		has_command nvim || brew install neovim
		version_at_least_0120 "$(nvim_version)" || die "Homebrew provided a Neovim version older than 0.12.0"
	else
		install_linux_nvim
		version_at_least_0120 "$(nvim_version)" || die "Downloaded Neovim is older than 0.12.0"
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

prefer_homebrew_node24() {
	local node_prefix
	node_prefix="$(brew --prefix node@24 2>/dev/null || true)"
	if [[ -x "$node_prefix/bin/node" && -x "$node_prefix/bin/npm" ]]; then
		NODE_BIN_DIR="$node_prefix/bin"
		export PATH="$NODE_BIN_DIR:$PATH"
	fi
}

ensure_node_runtime() {
	if [[ "$(uname -s)" == "Darwin" ]]; then
		prefer_homebrew_node24
		if ! node_is_ready; then
			log "Homebrew Node.js 24 is not runnable; reinstalling it"
			brew reinstall node@24
			prefer_homebrew_node24
		fi
	else
		prefer_local_node
		if [[ ! -x "$NODE_PREFIX/bin/node" || ! -x "$NODE_PREFIX/bin/npm" ]] ||
			! node_is_ready; then
			install_linux_node
		fi
	fi

	node_is_ready ||
		die "Node.js 24 LTS and npm are required for the JavaScript tools"
	log "Using Node.js $(node --version) and npm $(npm --version)"
}

install_python_tools() {
	log "Installing Python tools with uv"
	uv tool install --upgrade ty
	uv tool install --upgrade ruff
}

install_node_tools() {
	node_is_ready ||
		die "Node.js 24 LTS and npm are required for the JavaScript tools"

	mkdir -p "$NPM_PREFIX"
	npm config set prefix "$NPM_PREFIX"
	log "Installing JavaScript and TypeScript tools with npm ($(node --version), npm $(npm --version))"
	# typescript-language-server uses the JavaScript tsserver, which TypeScript 7 no longer ships.
	npm install --global --prefer-offline \
		eslint \
		eslint_d \
		prettier \
		typescript@^6.0.0 \
		typescript-language-server

	local npm_root
	npm_root="$(npm root --global)"
	[[ -f "$npm_root/typescript/lib/tsserver.js" ]] ||
		die "The installed TypeScript package does not provide tsserver.js"
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
	has_command taplo &&
		taplo lsp --help >/dev/null 2>&1 &&
		taplo fmt --help >/dev/null 2>&1
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
	x86_64 | amd64) architecture="x86_64" ;;
	aarch64 | arm64) architecture="aarch64" ;;
	*) die "Unsupported architecture for Taplo: $(uname -m)" ;;
	esac

	local archive="$TMP_DIR/taplo-${platform}-${architecture}.gz"
	local binary="$BIN_DIR/taplo.new"
	local url="https://github.com/tamasfe/taplo/releases/latest/download/taplo-${platform}-${architecture}.gz"
	log "Installing Taplo with TOML language-server support"
	curl --fail --location --silent --show-error --retry 3 "$url" --output "$archive"
	gzip -cd "$archive" >"$binary"
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
	[[ "$(uname -s)" == "Darwin" || "$(uname -s)" == "Linux" ]] ||
		die "Only macOS and Linux are supported"

	mkdir -p "$BIN_DIR"

	if [[ "$(uname -s)" == "Darwin" ]]; then
		install_macos_packages
	else
		install_ubuntu_packages
	fi

	ensure_node_runtime
	configure_shell_path

	ensure_neovim
	ensure_lazy
	ensure_uv
	install_python_tools
	install_node_tools
	install_gopls
	ensure_taplo
	ensure_tree_sitter_cli
	ensure_fd_alias
	link_config
	install_plugins

	log "Neovim setup is complete"
	log "Open a new shell before using user-local commands installed under $BIN_DIR"
}

main "$@"
