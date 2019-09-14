" vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" git interface
Plugin 'tpope/vim-fugitive'

" filesystem
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'ctrlpvim/ctrlp.vim'

" markdown
Plugin 'jtratner/vim-flavored-markdown'
Plugin 'JamshedVesuna/vim-markdown-preview'

" syntax checking
Plugin 'w0rp/ale'

" auto-completion stuff
Plugin 'Shougo/deoplete.nvim'
Plugin 'roxma/nvim-yarp'
Plugin 'roxma/vim-hug-neovim-rpc'
Plugin 'ervandew/supertab'

" code folding
Plugin 'tmhedberg/SimpylFold'

" commenting
Plugin 'scrooloose/nerdcommenter'

" Appearance
Plugin 'altercation/vim-colors-solarized'
Plugin 'jnurmine/Zenburn'
Plugin 'vim-airline/vim-airline'

" Python
Plugin 'Vimjas/vim-python-pep8-indent'

" Send to screen
Plugin 'jpalardy/vim-slime'

" toml
Plugin 'cespare/vim-toml'

" csv
Plugin 'chrisbra/csv.vim'


call vundle#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on    " enables filetype detection

" Splits
set splitbelow
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

augroup CursorLineOnlyInActiveWindow   " active line indicator on active split
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

" Code folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za
let g:SimplyFold_docstring_preview=1

" autocomplete
let g:deoplete#enable_at_startup=1
set wildmode=longest:full,full

" Swap file status
set noswapfile

" line numbering on
set nu

"------------Start Python PEP 8 stuff----------------
" Number of spaces that a pre-existing tab is equal to.
au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4

" spaces for indents
au BufRead,BufNewFile *.py,*pyw set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw set expandtab
au BufRead,BufNewFile *.py set softtabstop=4

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" Wrap text after a certain number of characters
" au BufRead,BufNewFile *.py,*.pyw, set textwidth=100

" Use UNIX (\n) line endings.
au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix

" Set the default file encoding to UTF-8:
set encoding=utf-8

" For full syntax highlighting:
let python_highlight_all=1
syntax on

" Keep indentation level from previous line:
autocmd FileType python set autoindent

" make backspaces more powerfull
set backspace=indent,eol,start


"Folding based on indentation:
autocmd FileType python set foldmethod=indent
"use space to open folds
nnoremap <space> za
"----------Stop python PEP 8 stuff--------------

"js stuff"
autocmd FileType javascript setlocal shiftwidth=2

" Number of spaces that a pre-existing tab is equal to.
au BufRead,BufNewFile *.js,*.sql set tabstop=2

" spaces for indents
au BufRead,BufNewFile *.js,*.sql,*.toml set shiftwidth=2
au BufRead,BufNewFile *.js,*.sql,*.toml set expandtab
au BufRead,BufNewFile *.js,*.sql,*.toml set softtabstop=2

" golang
autocmd Filetype go setlocal tabstop=2
autocmd Filetype go setlocal shiftwidth=2

" Color
if has('gui_running')
  set background=dark
  colorscheme solarized
else
  colorscheme zenburn
endif

" for git, add spell checking and automatic wrapping at 72 columns
autocmd Filetype gitcommit setlocal spell textwidth=72

" NERDTree settings
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree
autocmd VimEnter * wincmd p
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeShowHidden=1

" yank goes to clipboard
set clipboard=unnamed

" backspace behaviour
set backspace=indent,eol,start

" Github-flavored Markdown
let vim_markdown_preview_github=1
let vim_markdown_preview_browser='Google Chrome'
let vim_markdown_preview_hotkey='<C-m>'

" Pydiction tab completion
let g:pydiction_location = '~/.vim/bundle/Pydiction/complete-dict'

" spaces vs tabs
" Number of spaces that a pre-existing tab is equal to.
au BufRead,BufNewFile *.md,*.json set tabstop=2

" spaces for indents
au BufRead,BufNewFile *.md,*.json,*.yml,*.yaml set shiftwidth=2
au BufRead,BufNewFile *.md,*.json,*.yml,*.yaml set expandtab
au BufRead,BufNewFile *.md,*.json,*.yml,*.yaml set softtabstop=2

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Linting
let g:ale_linters = {'javascript': ['eslint'], 'python': ['flake8'], 'sql': ['sqlint']}
let g:ale_fixers = {'javascript': ['prettier'], 'python': ['black'], 'sql': ['sqlint']}
let g:ale_fix_on_save = 0
noremap <c-m> :ALEFix<CR>

" Auto-remove trailing whitespace
autocmd BufWritePre * %s/\s\+$//e
