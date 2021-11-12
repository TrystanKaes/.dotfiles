#!/bin/bash

for filename in "$HOME"/.dotfiles/system/.*; do
    if [ -f "$filename" ]; then
        # shellcheck disable=SC1090
        source "$filename";
    fi;
done

export BASH_SILENCE_DEPRECATION_WARNING=1
