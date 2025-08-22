#!/bin/sh

chsh -s /bin/bash

for filename in \
    "$HOME"/.dotfiles/runcom/.* \
    "$HOME"/.dotfiles/profiles/.* \
    "$HOME"/.dotfiles/git/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        cd "$HOME" && ln -sfv "$filename" "$HOME"
    fi
done

git config --global core.excludesfile ~/.gitignore_global

# shellcheck disable=SC1091
. "$HOME/.bashrc"


######## BEGIN MacOS Specific Options ########
if [ "$(uname)" = "Darwin" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #homebrew

  brew install 'mas' # Use homebrew to manage appstore things

  brew bundle install # Install apps/tools from the Brewfile

  # "$HOME"/.dotfiles/preferences/apply_plist_preferences.sh

  # "$HOME"/.dotfiles/preferences/osxdefaults
fi

# Optionally clear all (default) app icons from the Dock
read -p "Do you want to clear all Dock apps? (y/n): " clear_dock
if [[ "$clear_dock" =~ ^[Yy]$ ]]; then
  defaults write com.apple.dock persistent-apps -array
  echo "All Dock apps cleared."
fi
######## END MacOS Specific Options ########



