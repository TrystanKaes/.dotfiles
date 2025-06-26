## Trystan's Dotfiles!

Environment customizations for a POSIX shell and macOS system configuration. This is made with macOS in mind but most of it is POSIX compliant and should work on Linux/Unix machines.

## Quick Install

```sh
git clone https://github.com/TrystanKaes/.dotfiles.git
cd .dotfiles/ && sh setup.sh
```

## 📁 Repository Structure

### Core Configuration

- **`runcom/`** - Shell configuration files (`.bashrc`, `.tmux.conf`, `.curlrc`, `.inputrc`)
- **`profiles/`** - Shell profile files (`.bash_profile`, `.profile`)
  - MacOS (for instance) doesn't do `.bashrc`s. WTF Mac?
- **`git/`** - Git configuration (`.gitconfig`, `.gitignore_global`)
- **`system/`** - Core system files (`.functions`, `.alias`, `.path`, `.prompt`)

### macOS Specific

- **`preferences/`** - macOS system preferences and plist configurations
- **`brewfile`** - Homebrew package definitions
- **`misc/`** - Hardware configurations (Keychron Q2 keyboard, Terminal profiles)

### Utilities

- **`bin/`** - Custom shell scripts and utilities
- **`local/`** - Local-only files (excluded from git, sourced on terminal load)

## Shell Features

### Custom Functions

- **`ihp`** - "I Hate Python" - Simplified Python virtual environment management
- **`gopen`** - Open current git repository in browser
- **`gpr`** - GitHub PR management (create/open)
  - Might work with other git providers... I think it does.
- **`new_branch`** - Create and push new feature branches
- **`cleanup_branches`** - Enhanced branch cleanup with safety checks
- **`bpr`** - Quick PR creation from current branch
  - IS THIS A DUPE?
- **`backupToUsb`** - Backup Documents, Projects, Downloads, and Work to USB
- **`hello`** - Infinite text-to-speech loop (with Asimov's Laws of Robotics)
- **`kat`** - Cat files with rainbow colors (lolcat)
- **`clearKafkaTopics`** - Interactive Kafka topic cleanup

### Aliases

- **Navigation**: `..`, `...`, `....` for quick directory traversal
- **Git shortcuts**: `ga`, `gc`, `wip`, `gri`, `gr`, `gco`, `gush`, `gull`, `gup`, `gs`, `gp`
- **Docker**: `doc`, `dc`, `deef`, `drmi`, `dvol`, `dclean`, `dprune`
- **Kubernetes**: `k`, `kc`
- **System**: `mem`, `ttop`, `hosts`, `pingoo`, `rmds_store`

### Custom Prompt

- Shows username, hostname, current directory, and git status
- Color-coded git information (branch, commits ahead/behind, changed files)
- Truncated path display for long directories
- Exit code indication

## macOS Configuration

### System Preferences

The setup script automatically applies:

- **Homebrew installation** and package management
- **App Store app management** via `mas`
- **System preferences** via `osxdefaults`
- **Plist configurations** via `apply_plist_preferences.sh`

### Hardware Configurations

- **Keychron Q2 keyboard** - Custom key mappings and layers
- **Terminal profiles** - Custom terminal appearance settings

## Installation Options

The setup script includes macOS-specific options that are automatically enabled on macOS:

```sh
######## BEGIN MacOS Specific Options ########
# Homebrew installation
# App Store app management via mas
# Package installation from Brewfile
# System preferences application
# Strip Dock of all apps (optional but useful for all that faff that is included by default on new laptops)
######## END MacOS Specific Options ########
```

## Local Customizations

Files in the `local/` directory are:

1. Excluded from git pushes
2. Automatically sourced on terminal load if prefixed with `.`

Useful for machine-specific configurations and sensitive data.

## 🎯 Usage Examples

```sh
# Git workflow
new_branch branch_name
# ... work on thing ...
ga && gc
# or
wip

# Python development
ihp init
ihp start
# or
ihp bam

# Docker development
deef  # Stop, remove, rebuild, and start containers

# System utilities
backupToUsb  # Backup to USB drive
```
