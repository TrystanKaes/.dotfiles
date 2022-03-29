#!/bin/sh

chsh -s /bin/bash

for filename in \
    "$HOME"/.dotfiles/runcom/.* \
    "$HOME"/.dotfiles/profiles/.* \
    "$HOME"/.dotfiles/git/.* \
; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        cd "$HOME" && ln -sfv "$filename" "$HOME"
    fi;
done

git config --global core.excludesfile ~/.gitignore_global

cat > system/.local.gitnosync <<SCRIPT
#!/bin/bash

# The contents of this file will be ignored by github version control.
# All local configurations and system secrets go here
# and will be sourced when the rc is loaded.

SCRIPT

# shellcheck disable=SC1091
. "$HOME/.bashrc"

######## BEGIN MacOS Specific Options ########
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #homebrew

# brew tap homebrew/core

# brew install 'mas' # Use homebrew to manage appstore things

# brew bundle install # Install apps/tools from the Brewfile

# source .osxdefaults # Apply settings included in the osxdefaults file
######## END MacOS Specific Options ########
