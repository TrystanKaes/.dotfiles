#!/bin/sh

chsh -s /bin/bash

ln -sfv ".dotfiles/runcom/.bashrc" ~
ln -sfv ".dotfiles/runcom/.bash_profile" ~
ln -sfv ".dotfiles/runcom/.curlrc" ~
ln -sfv ".dotfiles/git/.gitconfig" ~

echo "Setting case insensitive directory navigation..."

echo 'set completion-ignore-case On' | sudo tee -a /etc/inputrc

source ~/.bashrc

######## BEGIN MacOS Specific Options ########
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #homebrew

# brew install 'mas' # Appstore

# brew bundle # Bunch of (potentially uneeded) env stuff

# sh osxdefaults.sh # Bunch of (potentially unwanted) settings
######## END MacOS Specific Options ########
