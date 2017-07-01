# Installation

```bash
$ brew install vim --with-python3
$ git clone https://github.com/oliverxchen/vim-config.git ~/vim-config
$ cd ~/vim-config
$ ./setup_vim.sh
```

### Auto-complete installation
```bash
$ cd ~/.vim/bundle/YouCompleteMe
$ ./install.py                   # Option 1: no JS support
$ ./install.py --tern-completed  # Option 2: JS support (need Node.js and npm installed)
```

### Markdown preview installation

```bash
$ brew install grip
```

# Usage

* [Slime](https://github.com/jpalardy/vim-slime): open a new pane in terminal along with vim, start a named screen session (eg `screen -S vim_out`), back in vim select text and `<Ctrl-cc>` will send text to the screen session. If you don't select text, the whole paragraph will be sent.
* [CtrlP](https://github.com/ctrlpvim/ctrlp.vim): `<Ctrl-p>` for a fuzzy file finder.
* [NERDTree](https://github.com/scrooloose/nerdtree): to open a folder explorer, `:NERDTree` within vim.
* [Markdown preview](https://github.com/JamshedVesuna/vim-markdown-preview): When editing a markdown file, `<Ctrl-m>`. Preview will appear in Chrome. `<Ctrl-m>` to refresh.
