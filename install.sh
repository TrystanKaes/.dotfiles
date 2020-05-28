#!/bin/sh

ln -sfv ".dotfiles/runcom/.bash_profile" ~
ln -sfv ".dotfiles/git/.gitconfig" ~

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" #homebrew

tap 'caskroom/cask' #library
brew 'mas' #appstore

source "~/.bash_profile"
