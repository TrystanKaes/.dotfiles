#!/bin/bash

# shellcheck disable=SC1091
source "$HOME/.dotfiles/runcom/.bashrc"


# worktree-switcher
eval "$(worktree-switcher init)"

# too-many-agents
eval "$(too-many-agents init)"
