#!/bin/bash

for filename in "$HOME"/.dotfiles/system/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename";
    fi;
done

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain
