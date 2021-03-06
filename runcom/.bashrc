# for DOTFILE in `~/.dotfiles/system`
# do
#   [ -f “$DOTFILE” ] && source “$DOTFILE”
# done

source ~/.dotfiles/system/.alias
source ~/.dotfiles/system/.env
source ~/.dotfiles/system/.functions
source ~/.dotfiles/system/.path
source ~/.dotfiles/system/.prompt
source ~/.dotfiles/runcom/.inputrc

export BASH_SILENCE_DEPRECATION_WARNING=1