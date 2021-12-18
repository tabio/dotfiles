#! /bin/bash
gem install solargraph

curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein-installer.sh

sh ./dein-installer.sh ~/.cache/dein

if [ ! -d ~/.config ]
then
  mkdir ~/.config
fi

ln -sf ~/dotfiles/nvim ~/.config/nvim
