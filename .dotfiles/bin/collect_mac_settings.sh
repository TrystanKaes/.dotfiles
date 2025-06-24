#!/bin/bash

# collect_mac_settings.sh - Collect all Mac settings and filter out defaults
# Usage: ./collect_mac_settings.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFERENCES_DIR="$(dirname "$SCRIPT_DIR")/preferences"
TEMP_DIR="$(mktemp -d)"
MASTERLIST_FILE="$PREFERENCES_DIR/masterlist.json"

# Create preferences directory if it doesn't exist
mkdir -p "$PREFERENCES_DIR"

echo "🚀 Collecting Mac settings from plists..."
echo "📁 Temp directory: $TEMP_DIR"
echo "📄 Output file: $MASTERLIST_FILE"

# Function to convert plist to JSON
convert_plist_to_json() {
    local domain="$1"
    local output_file="$2"
    
    echo "  Processing: $domain"
    
    # Export the plist
    if defaults export "$domain" - > "$TEMP_DIR/tmp.xml" 2>/dev/null; then
        # Convert to JSON using Python
        python3 -c "
import plistlib
import json
import sys

try:
    with open('$TEMP_DIR/tmp.xml', 'rb') as f:
        plist_data = plistlib.load(f)
    
    # Custom serializer for non-JSON serializable objects
    def json_serializer(obj):
        if hasattr(obj, 'isoformat'):  # datetime objects
            return obj.isoformat()
        elif isinstance(obj, bytes):
            try:
                return obj.decode('utf-8')
            except UnicodeDecodeError:
                return '<binary data>'
        else:
            return str(obj)
    
    json_data = json.dumps(plist_data, indent=2, default=json_serializer, sort_keys=True)
    
    with open('$output_file', 'w') as f:
        f.write(json_data)
        
except Exception as e:
    print(f'Error processing $domain: {e}', file=sys.stderr)
    sys.exit(1)
"
        rm -f "$TEMP_DIR/tmp.xml"
        return 0
    else
        echo "    ⚠️  Could not export $domain"
        return 1
    fi
}

# Common Mac application domains to check
DOMAINS=(
    # System Preferences
    "com.apple.systempreferences"
    "com.apple.preference.datetime"
    "com.apple.preference.displays"
    "com.apple.preference.dock"
    "com.apple.preference.expose"
    "com.apple.preference.keyboard"
    "com.apple.preference.mouse"
    "com.apple.preference.trackpad"
    "com.apple.preference.sound"
    "com.apple.preference.universalaccess"
    "com.apple.preference.sharing"
    "com.apple.preference.security"
    "com.apple.preference.network"
    "com.apple.preference.users"
    
    # Core System
    "com.apple.finder"
    "com.apple.dock"
    "com.apple.menuextra.clock"
    "com.apple.menuextra.battery"
    "com.apple.loginwindow"
    "com.apple.screensaver"
    "com.apple.screencapture"
    "com.apple.spotlight"
    "com.apple.LaunchServices"
    "com.apple.desktop"
    "com.apple.spaces"
    "com.apple.TimeMachine"
    "com.apple.CrashReporter"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    "com.apple.driver.AppleHIDMouse"
    "com.apple.AppleMultitouchTrackpad"
    "com.apple.universalaccess"
    "com.apple.HIToolbox"
    "com.apple.symbolichotkeys"
    "com.apple.NSGlobalDomain"
    "com.apple.WindowManager"
    
    # Applications
    "com.apple.Safari"
    "com.apple.mail"
    "com.apple.TextEdit"
    "com.apple.calculator"
    "com.apple.ActivityMonitor"
    "com.apple.Console"
    "com.apple.Terminal"
    "com.apple.Preview"
    "com.apple.QuickTimePlayerX"
    "com.apple.iTunes"
    "com.apple.Music"
    "com.apple.TV"
    "com.apple.Photos"
    "com.apple.iCal"
    "com.apple.AddressBook"
    "com.apple.Notes"
    "com.apple.Reminders"
    "com.apple.Maps"
    "com.apple.FaceTime"
    "com.apple.Messages"
    "com.apple.Keychain Access"
    "com.apple.archiveutility"
    "com.apple.BluetoothFileExchange"
    "com.apple.DigitalColorMeter"
    "com.apple.DiskUtility"
    "com.apple.FontBook"
    "com.apple.grapher"
    "com.apple.ImageCaptureCore"
    "com.apple.installer"
    "com.apple.keychainaccess"
    "com.apple.MigrationAssistant"
    "com.apple.NetworkUtility"
    "com.apple.SystemProfiler"
    "com.apple.VoiceOverUtility"
    
    # Third-party common apps (these might not exist)
    "com.google.Chrome"
    "com.microsoft.VSCode"
    "com.apple.dt.Xcode"
    "com.jetbrains.intellij"
    "com.sublimetext.3"
    "com.github.atom"
    "com.spotify.client"
    "com.slack.Slack"
    "com.tinyspeck.slackmacgap"
    "com.adobe.Photoshop"
    "com.adobe.Illustrator"
    "com.sketch.sketch3"
    "com.figma.Desktop"
    "com.postmanlabs.mac"
    "com.docker.docker"
    "com.1password.1password"
    "com.agilebits.onepassword7"
    "com.dropbox.Dropbox"
    "com.googlecode.iterm2"
    "org.videolan.vlc"
    "com.apple.dt.CommandLineTools"
)

# Also check for any plist files in standard locations
echo "📂 Scanning for additional plist files..."
ADDITIONAL_DOMAINS=()

# Check ~/Library/Preferences
if [ -d "$HOME/Library/Preferences" ]; then
    while IFS= read -r -d '' plist_file; do
        domain=$(basename "$plist_file" .plist)
        if [[ "$domain" != "com.apple.finder" && "$domain" != "ByHost" ]]; then
            ADDITIONAL_DOMAINS+=("$domain")
        fi
    done < <(find "$HOME/Library/Preferences" -name "*.plist" -type f -print0 2>/dev/null)
fi

# Merge and deduplicate domains
ALL_DOMAINS=($(printf '%s\n' "${DOMAINS[@]}" "${ADDITIONAL_DOMAINS[@]}" | sort -u))

echo "📋 Found ${#ALL_DOMAINS[@]} domains to process"

# Process each domain
mkdir -p "$TEMP_DIR/domains"
PROCESSED_DOMAINS=()

for domain in "${ALL_DOMAINS[@]}"; do
    output_file="$TEMP_DIR/domains/${domain}.json"
    if convert_plist_to_json "$domain" "$output_file"; then
        PROCESSED_DOMAINS+=("$domain")
    fi
done

echo "✅ Successfully processed ${#PROCESSED_DOMAINS[@]} domains"

# Create the masterlist JSON
echo "📝 Creating masterlist.json..."

python3 -c "
import json
import os
import sys
from pathlib import Path

# Load Apple defaults from external file
APPLE_DEFAULTS = {}
defaults_file = '$PREFERENCES_DIR/apple_defaults.json'
if os.path.exists(defaults_file):
    try:
        with open(defaults_file, 'r') as f:
            APPLE_DEFAULTS = json.load(f)
    except Exception as e:
        print(f'Warning: Could not load Apple defaults from {defaults_file}: {e}', file=sys.stderr)
        APPLE_DEFAULTS = {}
else:
    print(f'Warning: Apple defaults file not found at {defaults_file}', file=sys.stderr)
    APPLE_DEFAULTS = {}

def filter_defaults(domain, settings):
    '''Remove settings that match Apple defaults'''
    if domain not in APPLE_DEFAULTS:
        return settings
    
    defaults = APPLE_DEFAULTS[domain]
    filtered = {}
    
    for key, value in settings.items():
        if key not in defaults or defaults[key] != value:
            filtered[key] = value
    
    return filtered

def deep_merge_dicts(dict1, dict2):
    '''Deep merge two dictionaries'''
    result = dict1.copy()
    for key, value in dict2.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge_dicts(result[key], value)
        else:
            result[key] = value
    return result

# Load all processed domains
masterlist = {}
domains_dir = Path('$TEMP_DIR/domains')

for json_file in domains_dir.glob('*.json'):
    domain = json_file.stem
    try:
        with open(json_file, 'r') as f:
            settings = json.load(f)
        
        # Filter out defaults
        filtered_settings = filter_defaults(domain, settings)
        
        # Only include if there are custom settings
        if filtered_settings:
            masterlist[domain] = filtered_settings
            
    except Exception as e:
        print(f'Error processing {domain}: {e}', file=sys.stderr)

# Sort domains alphabetically
masterlist = dict(sorted(masterlist.items()))

# Write masterlist
with open('$MASTERLIST_FILE', 'w') as f:
    json.dump(masterlist, f, indent=2, sort_keys=True)

print(f'📄 Masterlist created with {len(masterlist)} domains containing custom settings')
for domain in sorted(masterlist.keys()):
    print(f'  • {domain} ({len(masterlist[domain])} custom settings)')
"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✨ Done! Your custom Mac settings have been saved to:"
echo "   $MASTERLIST_FILE"
echo ""
echo "📊 Summary:"
echo "   • Processed ${#PROCESSED_DOMAINS[@]} domains"
echo "   • Filtered out Apple defaults"
echo "   • Saved only your custom settings"
echo ""
echo "💡 You can now use this file to:"
echo "   • Backup your personalized settings"
echo "   • Apply them to a new Mac"
echo "   • Track changes over time"