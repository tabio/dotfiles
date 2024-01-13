#! /bin/bash
if [ ! -d ~/.config ]
then
  mkdir ~/.config
fi

ln -sf ~/dotfiles/nvim ~/.config/nvim
