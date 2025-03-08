# install sheldon
if [ ! -d ~/.config ]
then
  mkdir ~/.config
fi

sheldon init --shell zsh
cp ./sheldon.toml ~/.config/sheldon/plugins.toml
sheldon lock --reinstall

cp ./zshrc ~/.zshrc
