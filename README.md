## Trystan's Dotfiles!

Enviroment customizations for a POSIX shell and some other misc setting stuff. This is made with MacOS in mind but most of it is POSIX compliant and should mostly work on Linux/Unix machines.

To Install:

```sh
git clone https://github.com/TrystanKaes/.dotfiles.git
cd .dotfiles/ && sh setup.sh
```

To Install the MacOS specific stuff uncomment the following block in `setup.sh` prior to running:
```sh
######## BEGIN MacOS Specific Options ########
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" #homebrew

# brew install 'mas' # Use homebrew to manage appstore things 

# brew bundle install # Install apps/tools from the Brewfile

# source .osxdefaults # Apply settings included in the osxdefaults file
######## END MacOS Specific Options ########
```
