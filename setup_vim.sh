#!/bin/bash

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -s ~/vim-config/vimrc ~/.vimrc
vim +PluginInstall +qall

echo ""
echo "Don't forget to install / update"
echo "    * YouCompleteMe"
echo "    * grip"
echo ""
echo "See: https://github.com/oliverxchen/vim-config/blob/master/README.md"

