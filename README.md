## Installation

```bash
$ brew install vim
$ git clone https://github.com/oliverxchen/vim-config.git ~/vim-config
$ cd ~/vim-config
$ ./setup_vim.sh
```

### Markdown preview installation

```bash
$ brew install grip
```

## Usage

* [Slime](https://github.com/jpalardy/vim-slime): open a new pane in terminal along with vim, start a named screen session (eg `screen -S vim_out`), back in vim select text and `<Ctrl-cc>` will send text to the screen session. If you don't select text, the whole paragraph will be sent.
* [CtrlP](https://github.com/ctrlpvim/ctrlp.vim): `<Ctrl-p>` for a fuzzy file finder.
* [NERDTree](https://github.com/scrooloose/nerdtree): to open a folder explorer, `:NERDTree` within vim.
* [Markdown preview](https://github.com/JamshedVesuna/vim-markdown-preview): When editing a markdown file, `<Ctrl-m>`. Preview will appear in Chrome. `<Ctrl-m>` to refresh.
* There will be an error on startup of vim 8 if you don't follow these steps:
  * Find out what python version vim is using: `:pythonx import sys; print(sys.path)`
  * Note that path. As of this writing it was: `/opt/homebrew/opt/python@3.9/`.
  * In a terminal, pip install pynvim to that python version (which is not the global python version):
  ```bash
  PATH="/opt/homebrew/opt/python@3.9/bin:$PATH" pip3 install pynvim
  ```


# vim mode in VS Code

Execute the following command in a terminal to allow holding a direction to scroll:
```
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

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
    }
]
```
