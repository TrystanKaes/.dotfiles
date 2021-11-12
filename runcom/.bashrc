#!/bin/bash

for filename in "$HOME"/.dotfiles/system/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename";
    fi;
done

# shellcheck disable=SC1091
source "$HOME/.dotfiles/runcom/.inputrc"

export BASH_SILENCE_DEPRECATION_WARNING=1
