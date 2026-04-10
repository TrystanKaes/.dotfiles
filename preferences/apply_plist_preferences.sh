#!/bin/sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JSON="$SCRIPT_DIR/plist_preferences.json"

python3 - "$JSON" <<'PYEOF'
import sys, json, tempfile, subprocess, os
import plistlib

def expand_vars(obj):
    if isinstance(obj, str):
        return os.path.expandvars(obj)
    elif isinstance(obj, dict):
        return {k: expand_vars(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [expand_vars(i) for i in obj]
    return obj

json_file = sys.argv[1]
with open(json_file) as f:
    prefs = json.load(f)

for domain, settings in prefs.items():
    settings = expand_vars(settings)
    with tempfile.NamedTemporaryFile(suffix='.plist', delete=False) as tmp:
        plistlib.dump(settings, tmp, fmt=plistlib.FMT_XML)
        tmp_path = tmp.name
    try:
        subprocess.run(['defaults', 'import', domain, tmp_path], check=True)
        print(f"Applied preferences for {domain}")
    finally:
        os.unlink(tmp_path)
PYEOF
