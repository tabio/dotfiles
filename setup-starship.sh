#! /bin/bash
if [ ! -d ~/.config ]
then
  mkdir ~/.config
fi

ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml
