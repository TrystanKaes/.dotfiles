#!/bin/sh

chsh -s /bin/bash

ln -sfv ".dotfiles/runcom/.bashrc" ~
ln -sfv ".dotfiles/git/.gitconfig" ~

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" #homebrew

tap 'caskroom/cask' #library
brew 'mas' #appstore

source "~/.bashrc"
