#!/usr/bin/env bash

set -euo pipefail

is_macos() { [ "$(uname)" = "Darwin" ]; }

######## macOS-specific setup ########
if is_macos; then

  # Change default shell to bash (only if needed)
  if [ "$SHELL" != "/bin/bash" ]; then
    chsh -s /bin/bash
  fi

  # Install Homebrew if not already present
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle install  # Install apps/tools from the Brewfile

  # Apply macOS system preferences (sudo required for some settings in osxdefaults)
  "$HOME/.dotfiles/preferences/apply_plist_preferences.sh"
  "$HOME/.dotfiles/preferences/osxdefaults"

  # Set up app configs
  "$HOME/.dotfiles/misc/karabiner/install"
  "$HOME/.dotfiles/misc/magnet/install"
  "$HOME/.dotfiles/misc/bartender/install"

  # Optionally clear all (default) app icons from the Dock
  read -rp "Do you want to clear all Dock apps? (y/n): " clear_dock || true
  if [[ "$clear_dock" =~ ^[Yy]$ ]]; then
    defaults write com.apple.dock persistent-apps -array
    echo "All Dock apps cleared."
  fi

fi
######## end macOS-specific setup ########

# Symlink dotfiles into $HOME
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
