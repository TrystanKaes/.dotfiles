#!/bin/bash

set -euo pipefail

PREFS_JSON="preferences/plist_preferences.json"

if ! command -v jq >/dev/null; then
  echo "jq is required. Install with 'brew install jq' or similar."
  exit 1
fi

if [ ! -f "$PREFS_JSON" ]; then
  echo "Preferences JSON not found: $PREFS_JSON"
  exit 1
fi

# Helper to convert JSON value to macOS plist type
json_to_plist_type() {
  local value="$1"
  local type="$2"
  case "$type" in
    boolean) echo "bool" ;;
    number) echo "integer" ;;
    string) echo "string" ;;
    *) echo "string" ;;
  esac
}

# Iterate over each domain in the JSON
jq -r 'to_entries[] | "\(.key)"' "$PREFS_JSON" | while read -r domain; do
  echo "Processing domain: $domain"
  # For each key in the domain
  jq -r --arg domain "$domain" '.[$domain] | to_entries[] | "\(.key)"' "$PREFS_JSON" | while read -r key; do
    # Get the value and its type
    value=$(jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key]' "$PREFS_JSON")
    type=$(jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key] | type' "$PREFS_JSON")

    # If the value is an object or array, use PlistBuddy
    if [[ "$type" == "object" || "$type" == "array" ]]; then
      # Write the nested structure using PlistBuddy
      # Write to ~/Library/Preferences/$domain.plist
      plist="$HOME/Library/Preferences/$domain.plist"
      echo "  Using PlistBuddy for nested key: $key"
      # Remove the key if it exists
      /usr/libexec/PlistBuddy -c "Delete :$key" "$plist" 2>/dev/null || true
      # Add the key as a dict or array
      if [[ "$type" == "object" ]]; then
        /usr/libexec/PlistBuddy -c "Add :$key dict" "$plist"
        # For each subkey, add it
        jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key] | to_entries[] | "\(.key)\t\(.value)\t\(.value|type)"' "$PREFS_JSON" | while IFS=$'\t' read -r subkey subval subtype; do
          plist_type=$(json_to_plist_type "$subval" "$subtype")
          /usr/libexec/PlistBuddy -c "Add :$key:$subkey $plist_type $subval" "$plist"
        done
      else
        /usr/libexec/PlistBuddy -c "Add :$key array" "$plist"
        # For each item, add it
        jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key][]' "$PREFS_JSON" | while read -r item; do
          /usr/libexec/PlistBuddy -c "Add :$key: string $item" "$plist"
        done
      fi
    else
      # Use defaults write for flat keys
      echo "  Using defaults write for $key ($type): $value"
      case "$type" in
        boolean)
          if [[ "$value" == "true" ]]; then
            defaults write "$domain" "$key" -bool true
          else
            defaults write "$domain" "$key" -bool false
          fi
          ;;
        number)
          defaults write "$domain" "$key" -int "$value"
          ;;
        string)
          defaults write "$domain" "$key" "$value"
          ;;
        *)
          echo "  Skipping $key (unsupported type: $type)"
          ;;
      esac
    fi
  done
done

echo "All preferences applied."
