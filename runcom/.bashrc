#!/bin/bash

# Detect Homebrew prefix: Apple Silicon vs Intel
if [ "$(uname -m)" = "arm64" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

# Ghostty shell integration for Bash.
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

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
eval "$(worktree-switcher init)"
eval "$(diffnav completion bash)"

# Load NVM and add bash_completions
export NVM_DIR="$HOME/.nvm"
  [ -s "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh"
  [ -s "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"

# pnpm
export PNPM_HOME="/Users/trystankaes/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:/Users/trystankaes/.lmstudio/bin"

eval "$(zoxide init bash)"

# Re-emit OSC 7 after Ghostty's 133;C clears it, so splits inherit CWD during TUI sessions.
claude() {
  printf '\033]7;file://%s%s\007' "$HOSTNAME" "$PWD"
  command claude "$@"
}
