for DOTFILE in `find /Users/trystankaes/.dotfiles/system`
do
  [ -f “$DOTFILE” ] && source “$DOTFILE”
done

export EDITOR=nano
#export VISUAL='program'
