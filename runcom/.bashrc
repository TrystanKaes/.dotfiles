#!/bin/bash

for filename in "$HOME"/.dotfiles/system/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename";
    fi;
done

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain
