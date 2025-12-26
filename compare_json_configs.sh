#!/bin/bash

# HOCON Configuration Comparison Script
# Compares HOCON config files against default.conf and identifies missing keys

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

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed. Please install Python 3 to use this script.${NC}"
    exit 1
fi

# Check if pyhocon is installed
if ! python3 -c "import pyhocon" 2>/dev/null; then
    echo -e "${RED}Error: pyhocon is not installed. Please install pyhocon to use this script.${NC}"
    echo "Install with: pip3 install pyhocon"
    exit 1
fi

# Function to convert HOCON to JSON
hocon_to_json() {
    local file="$1"
    python3 -c "
import sys
from pyhocon import ConfigFactory

try:
    conf = ConfigFactory.parse_file('$file')
    import json
    print(json.dumps(conf))
except Exception as e:
    sys.stderr.write(f'Error parsing HOCON: {e}\n')
    sys.exit(1)
"
}

# Function to extract all keys recursively from a HOCON file
# Returns keys in dot notation (e.g., "parent.child.key")
get_all_keys() {
    local file="$1"
    local json_content=$(hocon_to_json "$file")

    if [ $? -ne 0 ] || [ -z "$json_content" ]; then
        return 1
    fi

    echo "$json_content" | jq -r '
        def flatten_keys:
            . as $in
            | reduce paths(scalars) as $path (
                {};
                . + {($path | map(tostring) | join(".")): $in | getpath($path)}
            )
            | keys[];
        flatten_keys
    ' 2>/dev/null | sort -u
}

# Function to check if a key exists in a HOCON file
key_exists() {
    local file="$1"
    local key="$2"
    local json_content=$(hocon_to_json "$file")

    if [ $? -ne 0 ] || [ -z "$json_content" ]; then
        return 1
    fi

    # Convert dot notation to jq path
    local jq_path=$(echo "$key" | sed 's/\./","/g' | sed 's/^/["/' | sed 's/$/"]/')

    echo "$json_content" | jq -e "getpath($jq_path) != null" &>/dev/null
}

echo -e "${GREEN}=== HOCON Configuration Comparison ===${NC}"
echo -e "Default file: ${YELLOW}$DEFAULT_FILE${NC}\n"

# Get all keys from default.conf
echo "Extracting keys from $DEFAULT_FILE..."
default_keys=$(get_all_keys "$DEFAULT_FILE")

if [ $? -ne 0 ] || [ -z "$default_keys" ]; then
    echo -e "${RED}Error: No keys found in $DEFAULT_FILE or invalid HOCON format${NC}"
    exit 1
fi

key_count=$(echo "$default_keys" | wc -l)
echo -e "Found ${GREEN}$key_count${NC} keys in $DEFAULT_FILE\n"

# Find all conf files in current directory (excluding default.conf)
config_files=$(find . -maxdepth 1 -type f -name "*.conf" ! -name "$DEFAULT_FILE" -printf "%f\n" | sort)

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

    # Validate HOCON format by attempting to convert to JSON
    json_content=$(hocon_to_json "$config_file" 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}⨯ Invalid HOCON format, skipping${NC}\n"
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
