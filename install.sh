#!/bin/sh

chsh -s /bin/bash

ln -sfv ".dotfiles/runcom/.bashrc" ~
ln -sfv ".dotfiles/git/.gitconfig" ~

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #homebrew

brew install 'mas' #appstore

source ~/.bashrc
