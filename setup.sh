#!/usr/bin/env bash

set -euo pipefail

is_macos() { [ "$(uname)" = "Darwin" ]; }

######## macOS-specific setup ########
if is_macos; then

  # Install Homebrew if not already present
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle install  # Install apps/tools from the Brewfile

  # Change default shell to Homebrew bash (only if needed)
  HOMEBREW_BASH="$(brew --prefix)/bin/bash"
  if ! grep -qF "$HOMEBREW_BASH" /etc/shells; then
    echo "$HOMEBREW_BASH" | sudo tee -a /etc/shells
  fi
  if [ "$SHELL" != "$HOMEBREW_BASH" ]; then
    chsh -s "$HOMEBREW_BASH"
  fi

  # Apply macOS system preferences (sudo required for some settings in osxdefaults)
  "$HOME/.dotfiles/preferences/apply_plist_preferences.sh"
  "$HOME/.dotfiles/preferences/osxdefaults"

  # Set up app configs (symlinks for config-file apps)
  SYMLINK="$HOME/.dotfiles/bin/symlink"
  "$SYMLINK" misc/karabiner                              "$HOME/.config/karabiner"
  "$SYMLINK" misc/ghostty/config                         "$HOME/.config/ghostty/config"

  # Plist-based apps (copy, not symlink — cfprefsd and app writes break symlinks)
  PLIST_SYNC="$HOME/.dotfiles/bin/plist-sync"
  "$PLIST_SYNC" install bartender com.surteesstudios.Bartender "Bartender 5"
  "$PLIST_SYNC" install magnet    com.crowdcafe.windowmagnet   Magnet
  "$HOME/.dotfiles/misc/claude/install"

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
