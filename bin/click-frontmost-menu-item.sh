#!/bin/bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <process name> <menu item title> [<menu item title> ...]" >&2
  exit 1
fi

osascript - "$@" <<'EOF'
on run argv
    set processName to item 1 of argv
    set menuItemTitles to items 2 thru -1 of argv
    set commonMenus to {"App", "File", "Edit", "View", "Go", "Navigate", "Window", "Help"}

    tell application "System Events"
        set targetProcess to application process processName

        repeat with menuItemTitle in menuItemTitles
            set targetTitle to contents of menuItemTitle

            tell targetProcess
                repeat with menuBarItemName in commonMenus
                    try
                        tell menu bar item (contents of menuBarItemName) of menu bar 1
                            click (first menu item of menu 1 whose name is targetTitle)
                            return targetTitle
                        end tell
                    end try
                end repeat
            end tell
        end repeat
    end tell

    error "No matching menu item found."
end run
EOF
