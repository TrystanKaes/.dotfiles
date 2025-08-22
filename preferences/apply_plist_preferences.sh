#!/bin/bash

# XXX: This doesn't work yet.

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

# Recursive function to process JSON structure
process_json_value() {
  local domain="$1"
  local key_path="$2"
  local value="$3"
  local type="$4"
  local plist="$HOME/Library/Preferences/$domain.plist"

  # Validate that we got a proper type
  if [[ "$type" != "boolean" && "$type" != "number" && "$type" != "string" && "$type" != "object" && "$type" != "array" ]]; then
    echo "  Skipping $key_path (invalid type: $type)"
    return
  fi

  # If we've reached a primitive type, apply the preference
  if [[ "$type" == "boolean" || "$type" == "number" || "$type" == "string" ]]; then
    echo "  Applying $key_path ($type): $value"
    plist_type=$(json_to_plist_type "$value" "$type")
    /usr/libexec/PlistBuddy -c "Set :$key_path $plist_type $value" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :$key_path $plist_type $value" "$plist"
    return
  fi

  # For objects, iterate over keys and recurse
  if [[ "$type" == "object" ]]; then
    echo "  Processing object: $key_path"
    # Remove the key if it exists and add as dict
    /usr/libexec/PlistBuddy -c "Delete :$key_path" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :$key_path dict" "$plist"

    # Get all keys in this object
    jq -r --arg domain "$domain" --arg key_path "$key_path" 'getpath($key_path | split(".")) | to_entries[] | "\(.key)"' "$PREFS_JSON" | while read -r subkey; do
      local subvalue
      local subtype
      subvalue=$(jq -r --arg domain "$domain" --arg key_path "$key_path" --arg subkey "$subkey" 'getpath($key_path | split("."))[$subkey]' "$PREFS_JSON")
      subtype=$(jq -r --arg domain "$domain" --arg key_path "$key_path" --arg subkey "$subkey" 'getpath($key_path | split("."))[$subkey] | type' "$PREFS_JSON")

      local new_key_path
      if [[ "$key_path" == "" ]]; then
        new_key_path="$subkey"
      else
        new_key_path="$key_path.$subkey"
      fi

      process_json_value "$domain" "$new_key_path" "$subvalue" "$subtype"
    done
  fi

  # For arrays, add as array and add each item
  if [[ "$type" == "array" ]]; then
    echo "  Processing array: $key_path"
    # Remove the key if it exists and add as array
    /usr/libexec/PlistBuddy -c "Delete :$key_path" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :$key_path array" "$plist"

    # Add each item to the array
    jq -r --arg domain "$domain" --arg key_path "$key_path" 'getpath($key_path | split("."))[]' "$PREFS_JSON" | while read -r item; do
      /usr/libexec/PlistBuddy -c "Add :$key_path: string $item" "$plist"
    done
  fi
}

# Iterate over each domain in the JSON
jq -r 'to_entries[] | "\(.key)"' "$PREFS_JSON" | while read -r domain; do
  echo "Processing domain: $domain"

  # For each key in the domain
  jq -r --arg domain "$domain" '.[$domain] | to_entries[] | "\(.key)"' "$PREFS_JSON" | while read -r key; do
    # Get the value and its type
    value=$(jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key]' "$PREFS_JSON")
    type=$(jq -r --arg domain "$domain" --arg key "$key" '.[$domain][$key] | type' "$PREFS_JSON")

    process_json_value "$domain" "$key" "$value" "$type"
  done
done

echo "All preferences applied."
