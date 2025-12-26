#!/bin/bash

# JSON Configuration Comparison Script
# Compares JSON config files against default.conf and identifies missing keys

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DEFAULT_FILE="default.conf"

# Check if default.conf exists
if [ ! -f "$DEFAULT_FILE" ]; then
    echo -e "${RED}Error: $DEFAULT_FILE not found in current directory${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Please install jq to use this script.${NC}"
    echo "Install with: sudo apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
    exit 1
fi

# Function to extract all keys recursively from a JSON file
# Returns keys in dot notation (e.g., "parent.child.key")
get_all_keys() {
    local file="$1"
    jq -r '
        def flatten_keys:
            . as $in
            | reduce paths(scalars) as $path (
                {};
                . + {($path | map(tostring) | join(".")): $in | getpath($path)}
            )
            | keys[];
        flatten_keys
    ' "$file" 2>/dev/null | sort -u
}

# Function to check if a key exists in a JSON file
key_exists() {
    local file="$1"
    local key="$2"

    # Convert dot notation to jq path
    local jq_path=$(echo "$key" | sed 's/\./","/g' | sed 's/^/["/' | sed 's/$/"]/')

    jq -e "getpath($jq_path) != null" "$file" &>/dev/null
}

echo -e "${GREEN}=== JSON Configuration Comparison ===${NC}"
echo -e "Default file: ${YELLOW}$DEFAULT_FILE${NC}\n"

# Get all keys from default.conf
echo "Extracting keys from $DEFAULT_FILE..."
default_keys=$(get_all_keys "$DEFAULT_FILE")

if [ -z "$default_keys" ]; then
    echo -e "${RED}Error: No keys found in $DEFAULT_FILE or invalid JSON${NC}"
    exit 1
fi

key_count=$(echo "$default_keys" | wc -l)
echo -e "Found ${GREEN}$key_count${NC} keys in $DEFAULT_FILE\n"

# Find all JSON/conf files in current directory (excluding default.conf)
config_files=$(find . -maxdepth 1 -type f \( -name "*.json" -o -name "*.conf" \) ! -name "$DEFAULT_FILE" -printf "%f\n" | sort)

if [ -z "$config_files" ]; then
    echo -e "${YELLOW}No other configuration files found to compare${NC}"
    exit 0
fi

echo -e "${GREEN}Configuration files to check:${NC}"
echo "$config_files" | sed 's/^/  - /'
echo ""

# Compare each file against default.conf
total_files=0
files_with_missing_keys=0

while IFS= read -r config_file; do
    total_files=$((total_files + 1))
    echo -e "${YELLOW}Checking: $config_file${NC}"

    # Validate JSON
    if ! jq empty "$config_file" 2>/dev/null; then
        echo -e "  ${RED}⨯ Invalid JSON format, skipping${NC}\n"
        continue
    fi

    missing_keys=()

    # Check each key from default.conf
    while IFS= read -r key; do
        if ! key_exists "$config_file" "$key"; then
            missing_keys+=("$key")
        fi
    done <<< "$default_keys"

    # Report results
    if [ ${#missing_keys[@]} -eq 0 ]; then
        echo -e "  ${GREEN}✓ All keys present${NC}\n"
    else
        files_with_missing_keys=$((files_with_missing_keys + 1))
        echo -e "  ${RED}⨯ Missing ${#missing_keys[@]} key(s):${NC}"
        for missing_key in "${missing_keys[@]}"; do
            echo -e "    ${RED}- $missing_key${NC}"
        done
        echo ""
    fi
done <<< "$config_files"

# Summary
echo -e "${GREEN}=== Summary ===${NC}"
echo -e "Total files checked: $total_files"
echo -e "Files with missing keys: ${RED}$files_with_missing_keys${NC}"
echo -e "Files with all keys: ${GREEN}$((total_files - files_with_missing_keys))${NC}"
