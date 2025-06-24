#!/bin/bash

# apply_mac_settings.sh - Apply Mac settings from masterlist.json
# Usage: ./apply_mac_settings.sh [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFERENCES_DIR="$(dirname "$SCRIPT_DIR")/preferences"
MASTERLIST_FILE="$PREFERENCES_DIR/masterlist.json"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🔍 Running in dry-run mode - no changes will be made"
fi

# Check if masterlist.json exists
if [[ ! -f "$MASTERLIST_FILE" ]]; then
    echo "❌ Error: masterlist.json not found at $MASTERLIST_FILE"
    echo "   Run collect_mac_settings.sh first to create the masterlist."
    exit 1
fi

echo "🚀 Applying Mac settings from masterlist.json..."
echo "📄 Reading from: $MASTERLIST_FILE"

# Function to apply settings for a domain
apply_domain_settings() {
    local domain="$1"
    local settings_json="$2"
    
    echo "  📁 Processing: $domain"
    
    # Convert JSON to defaults commands using Python
    python3 -c "
import json
import subprocess
import sys

def apply_setting(domain, key, value):
    '''Apply a single setting using defaults command'''
    cmd = ['defaults', 'write', domain, key]
    
    # Handle different value types
    if isinstance(value, bool):
        cmd.extend(['-bool', 'true' if value else 'false'])
    elif isinstance(value, int):
        cmd.extend(['-int', str(value)])
    elif isinstance(value, float):
        cmd.extend(['-float', str(value)])
    elif isinstance(value, str):
        cmd.extend(['-string', value])
    elif isinstance(value, list):
        # For arrays, we need to handle differently
        cmd.extend(['-array'])
        for item in value:
            if isinstance(item, str):
                cmd.append(item)
            else:
                cmd.append(str(item))
    elif isinstance(value, dict):
        # For dictionaries, we need to handle as plist
        cmd.extend(['-dict'])
        for k, v in value.items():
            cmd.append(k)
            if isinstance(v, bool):
                cmd.append('true' if v else 'false')
            else:
                cmd.append(str(v))
    else:
        cmd.extend(['-string', str(value)])
    
    return cmd

try:
    settings = json.loads('$settings_json')
    domain = '$domain'
    
    for key, value in settings.items():
        try:
            cmd = apply_setting(domain, key, value)
            
            if $DRY_RUN:
                print(f'    [DRY-RUN] Would run: {\" \".join(cmd)}')
            else:
                print(f'    ✓ Setting {key} = {value}')
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode != 0:
                    print(f'    ⚠️  Warning: Failed to set {key}: {result.stderr.strip()}')
                    
        except Exception as e:
            print(f'    ❌ Error setting {key}: {e}')
            
except Exception as e:
    print(f'Error processing domain {domain}: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Read and process the masterlist
python3 -c "
import json
import subprocess
import sys

try:
    with open('$MASTERLIST_FILE', 'r') as f:
        masterlist = json.load(f)
    
    print(f'📋 Found {len(masterlist)} domains with custom settings')
    
    # Process each domain
    for domain, settings in masterlist.items():
        settings_json = json.dumps(settings)
        
        # Call the bash function to apply settings
        cmd = ['bash', '-c', f'source \"$0\" && apply_domain_settings \"{domain}\" \"{settings_json}\"']
        
        try:
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            print(f'Error processing {domain}: {e}', file=sys.stderr)
            continue
    
    if not $DRY_RUN:
        print('')
        print('🔄 Restarting affected services...')
        
        # Restart services that need it
        services_to_restart = [
            ('Dock', 'killall Dock'),
            ('Finder', 'killall Finder'),
            ('SystemUIServer', 'killall SystemUIServer'),
            ('ControlStrip', 'killall ControlStrip'),
        ]
        
        for service_name, command in services_to_restart:
            try:
                print(f'  🔄 Restarting {service_name}...')
                subprocess.run(command.split(), check=False, capture_output=True)
            except Exception as e:
                print(f'  ⚠️  Could not restart {service_name}: {e}')
        
        print('')
        print('✨ Settings applied successfully!')
        print('💡 Some changes may require a logout/login or system restart to take full effect.')
        
    else:
        print('')
        print('🔍 Dry-run completed. No changes were made.')
        print('💡 Run without --dry-run to actually apply the settings.')
        
except Exception as e:
    print(f'Error reading masterlist: {e}', file=sys.stderr)
    sys.exit(1)
"