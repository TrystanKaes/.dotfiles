# ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
#
#
# test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$PATH"
# test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
# test -r ~/.bash_profile && echo 'export PATH="$(brew --prefix)/bin:$PATH"' >>~/.bash_profile
# echo 'export PATH="$(brew --prefix)/bin:$PATH"' >>~/.profile
# echo 'export PATH="$(brew --prefix)/bin:$PATH"' >>~/.bashrc

echo you did a linux
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
  then
  +    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
   fi

 fi
