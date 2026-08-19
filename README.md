# Neovim configuration

Personal Neovim configuration for macOS and Ubuntu Linux.

## Installation

The setup script installs or verifies Neovim and the command-line tools, creates a safe configuration symlink, installs the locked plugins, and is safe to run again.

It supports macOS and Ubuntu Linux. On macOS it installs Homebrew if needed. On Ubuntu it uses `sudo apt-get` for system prerequisites and installs Neovim and user tools without requiring root for the configuration.

The JavaScript and TypeScript tools use Node.js 24 LTS on both platforms. Treesitter uses Neovim's 0.12-compatible `nvim-treesitter` main branch; setup installs the required Tree-sitter CLI automatically.

```bash
git clone https://github.com/oliverxchen/vim-config.git ~/vim-config
cd ~/vim-config
./setup_nvim.sh
```

Open a new terminal after setup so the user-local tool paths take effect. Run `./setup_nvim.sh` again to update tools and reinstall the locked plugins. Use `:Lazy update` when you deliberately want newer plugin revisions, then review the lockfile.

## Included workflow

- `<C-p>` finds files; `:Fg` searches text; `:Fb` lists buffers; `:Fe` opens Oil.
- `:Z` toggles folds. Split navigation uses `<C-w>` followed by `h`, `j`, `k`, or `l`.
- `gc` and `gb` comment lines or blocks.
- Fugitive provides Git commands. Gitsigns and Lualine show the current branch and changed-line counts.
- The TypeScript language server, `ty`, `gopls`, and Taplo provide language intelligence when their tools apply.
- Conform formats supported files on save. Ruff, ESLint, and other linters report diagnostics separately.
- Swap files and persistent undo are enabled for recovery.

For troubleshooting, use `:checkhealth`, `:LspInfo`, and `:Lazy` inside Neovim. The configuration expects Neovim 0.12.0 or newer.

## VS Code/Cursor vim mode

Execute the following command in a terminal to allow holding a direction to scroll:

```
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

For cursor, find the app address:

```
cd /Applications
mdls -name kMDItemCFBundleIdentifier Cursor.app
```

And then use the output with the `defaults write` command.

Add the following to VSCode's `settings.json` to be able to yank into the system clipboard:

```
    "vim.useSystemClipboard": true
```

Go to the command pallete cmd+shift+P and select: "Preferences: Open Keyboard Shortcuts (JSON)"
add to the keybindings.json file

```
// Place your key bindings in this file to override the defaults
[
    {
        "key":     "cmd+j",
        "command": "workbench.action.terminal.focus"
    },
    {
        "key":     "cmd+j",
        "command": "workbench.action.focusActiveEditorGroup",
        "when":    "terminalFocus"
    },
    {
        "key":     "cmd+r",
        "command": "workbench.action.terminal.runSelectedText"
    },
    {
        "key": "shift+enter",
        "command": "-python.execInREPL",
        "when": "config.python.REPL.sendToNativeREPL && editorTextFocus && !accessibilityModeEnabled && !isCompositeNotebook && !jupyter.ownsSelection && !notebookEditorFocused && editorLangId == 'python'"
    },
    {
        "key": "shift+enter",
        "command": "-python.execSelectionInTerminal",
        "when": "editorTextFocus && !findInputFocussed && !isCompositeNotebook && !jupyter.ownsSelection && !notebookEditorFocused && !replaceInputFocussed && editorLangId == 'python'"
    },
    {
      "key": "cmd+i",
      "command": "composerMode.agent",
    },
    {
      "key": "shift+cmd+0",
      "command": "workbench.action.terminal.focusPrevious",
    },
    {
      "key": "shift+cmd+backspace",
      "command": "workbench.action.terminal.focusNext",
    },
]
```

User settings in VS Code:

```
{
  "dart.flutterSdkPath": "/Users/oliverchen/src/flutter",
  "editor.minimap.enabled": false,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "vim.useSystemClipboard": true,
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[javascript]": {
    "editor.tabSize": 2
  },
  "[javascriptreact]": {
    "editor.tabSize": 2
  },
  "[typescript]": {
    "editor.tabSize": 2
  },
  "[typescriptreact]": {
    "editor.tabSize": 2
  },
  "files.associations": {
    ".cursorrules": "plaintext"
  },
  "git.openRepositoryInParentFolders": "never",
  "editor.accessibilitySupport": "off",
  "git.confirmSync": false
}
```
