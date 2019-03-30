# Installation

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

# Usage

* [Slime](https://github.com/jpalardy/vim-slime): open a new pane in terminal along with vim, start a named screen session (eg `screen -S vim_out`), back in vim select text and `<Ctrl-cc>` will send text to the screen session. If you don't select text, the whole paragraph will be sent.
* [CtrlP](https://github.com/ctrlpvim/ctrlp.vim): `<Ctrl-p>` for a fuzzy file finder.
* [NERDTree](https://github.com/scrooloose/nerdtree): to open a folder explorer, `:NERDTree` within vim.
* [Markdown preview](https://github.com/JamshedVesuna/vim-markdown-preview): When editing a markdown file, `<Ctrl-m>`. Preview will appear in Chrome. `<Ctrl-m>` to refresh.
