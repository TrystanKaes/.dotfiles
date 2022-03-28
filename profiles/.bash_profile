#!/bin/bash

# shellcheck disable=SC1091
source "$HOME/.dotfiles/runcom/.bashrc"

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain

eval "$(/opt/homebrew/bin/brew shellenv)"

clear
