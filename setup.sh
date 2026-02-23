#!/bin/sh

set -e

CURRENT_DIR="`pwd`"
DOTFILES_DIR="$(dirname "$(realpath "$0")")"

sudo apt-get update > /dev/null
sudo apt-get install -y git curl zsh stow > /dev/null

read -p "Want to install VSCode?: [y/N]:" YN
if [ "$YN" = 'y' ];  then
  "$DOTFILES_DIR/.bin/install_code"
fi

read -p "Want to install docker?: [y/N]:" YN
if [ "$YN" = 'y' ];  then
  "$DOTFILES_DIR/.bin/install_docker"
fi

read -p "Want to install zen browser?: [y/N]:" YN
if [ "$YN" = 'y' ];  then
  "$DOTFILES_DIR/.bin/install_zen"
fi

read -p "Want to install cowsay and lolcat?: [y/N]:" YN
if [ "$YN" = 'y' ];  then
  sudo apt-get install -y cowsay lolcat > /dev/null
fi

mkdir -p "$HOME/.fonts"
cp "$CURRENT_DIR/fonts/JetBrainsMonoNLNerdFontMono-Regular.ttf" "$HOME/.fonts"
cd "$DOTFILES_DIR"
stow .
cd "$CURRENT_DIR"
sudo chsh -s /bin/zsh
zsh
