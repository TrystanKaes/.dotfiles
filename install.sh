#!/bin/sh

ln -sfv ".dotfiles/runcom/.bash_profile" ~
ln -sfv ".dotfiles/runcom/.inputrc" ~
ln -sfv ".dotfiles/git/.gitconfig" ~
ln -sfv ".dotfiles/runcom/.bashrc" ~
# ln -sfv ".dotfiles/runcom/.profile" ~
#ln -sfv ".dotfiles/runcom/.functions" ~
#ln -sfv ".dotfiles/runcom/.alias" ~
#ln -sfv ".dotfiles/runcom/.prompt" ~
#ln -sfv ".dotfiles/git/.gitignore_global" ~



source ~/.dotfiles/OS_sh/mac.sh

tap 'caskroom/cask' #library
brew 'mas' #appstore

brew cask install 'atom'
brew cask install 'github'
