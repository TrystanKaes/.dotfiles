#!/bin/bash

# Source all the system things.
for filename in "$HOME"/.dotfiles/system/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename"
    fi
done

# Source the local-only things like secrets.
for filename in "$HOME"/.dotfiles/local/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename"
    fi
done

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain

# Load NVM and add bash_completions
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
