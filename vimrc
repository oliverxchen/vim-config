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

" python syntax checker
Plugin 'nvie/vim-flake8'
Plugin 'vim-scripts/Pydiction'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'scrooloose/syntastic'
Plugin 'jmcantrell/vim-virtualenv'

" auto-completion stuff
Plugin 'Valloric/YouCompleteMe'
Plugin 'ervandew/supertab'

" code folding
Plugin 'tmhedberg/SimpylFold'

" commenting
Plugin 'scrooloose/nerdcommenter'

" Appearance
Plugin 'altercation/vim-colors-solarized'
Plugin 'jnurmine/Zenburn'
Plugin 'vim-airline/vim-airline'

" Be all end all
Plugin 'jpalardy/vim-slime'

call vundle#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on    " enables filetype detection

" Splits
set splitbelow
set splitright
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Code folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za
let g:SimplyFold_docstring_preview=1

" autocomplete
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

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
au BufRead,BufNewFile *.js set tabstop=2

" spaces for indents
au BufRead,BufNewFile *.js set shiftwidth=2
au BufRead,BufNewFile *.js set expandtab
au BufRead,BufNewFile *.js set softtabstop=2

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
autocmd VimEnter * wincmd p
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

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
au BufRead,BufNewFile *.md,*.json set shiftwidth=2
au BufRead,BufNewFile *.md,*.json set expandtab
au BufRead,BufNewFile *.md,*.json set softtabstop=2

" Add spaces after comment delimiters by default
" let g:NERDSpaceDelims = 1
