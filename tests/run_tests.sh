#!/bin/bash

# Test suite for HOCON configuration comparison script

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_CONFIGS_DIR="$SCRIPT_DIR/test-configs"
COMPARE_SCRIPT="$ROOT_DIR/compare_json_configs.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HOCON Configuration Comparison Test Suite${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    local should_match="${4:-true}"  # Default to expecting match

    TESTS_RUN=$((TESTS_RUN + 1))

    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"

    # Run the command and capture output
    output=$(eval "$test_command" 2>&1)
    exit_code=$?

    # Check if pattern matches
    if echo "$output" | grep -q "$expected_pattern"; then
        match_found=true
    else
        match_found=false
    fi

    # Determine if test passed
    if [ "$should_match" = "true" ] && [ "$match_found" = "true" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC}\n"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    elif [ "$should_match" = "false" ] && [ "$match_found" = "false" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC}\n"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗ FAILED${NC}"
        echo -e "  Expected pattern: $expected_pattern"
        echo -e "  Should match: $should_match"
        echo -e "  Match found: $match_found"
        echo -e "  Exit code: $exit_code"
        echo -e "  Output:\n$output\n"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Function to check specific missing keys
check_missing_keys() {
    local test_name="$1"
    local config_file="$2"
    shift 2
    local expected_keys=("$@")

    TESTS_RUN=$((TESTS_RUN + 1))

    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"

    # Run script from test-configs directory
    cd "$TEST_CONFIGS_DIR"
    output=$("$COMPARE_SCRIPT" 2>&1)
    cd "$ROOT_DIR"

    # Extract missing keys for the specific config file
    config_output=$(echo "$output" | sed -n "/Checking: $config_file/,/^$/p")

    # Check each expected missing key
    all_keys_found=true
    for key in "${expected_keys[@]}"; do
        if ! echo "$config_output" | grep -F -q -- "- $key"; then
            all_keys_found=false
            echo -e "  ${RED}Expected missing key not found: $key${NC}"
        fi
    done

    if [ "$all_keys_found" = "true" ]; then
        echo -e "  ${GREEN}✓ PASSED - All expected missing keys found${NC}\n"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗ FAILED${NC}"
        echo -e "  Output:\n$config_output\n"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Save current directory
ORIGINAL_DIR=$(pwd)

# Test 1: Complete configuration (all keys present)
echo -e "${BLUE}--- Basic Functionality Tests ---${NC}\n"

cd "$TEST_CONFIGS_DIR"
output=$("$COMPARE_SCRIPT" 2>&1 || true)
cd "$ORIGINAL_DIR"

if echo "$output" | grep -A 1 "Checking: complete.conf" | grep -q "✓ All keys present"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Complete config has all keys${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Complete config has all keys${NC}"
    echo -e "  ${RED}✗ FAILED${NC}\n"
fi

# Test 2: Check partial.conf has specific missing keys
check_missing_keys \
    "Partial config missing specific keys" \
    "partial.conf" \
    "database.credentials.password" \
    "database.credentials.username" \
    "server.timeout" \
    "logging.rotation.enabled" \
    "logging.rotation.maxSize"

# Test 3: Check minimal.conf has many missing keys
check_missing_keys \
    "Minimal config missing many keys" \
    "minimal.conf" \
    "database.name" \
    "database.credentials.username" \
    "database.credentials.password" \
    "server.host" \
    "server.timeout"

# Test 4: Invalid HOCON syntax should be skipped
cd "$TEST_CONFIGS_DIR"
output=$("$COMPARE_SCRIPT" 2>&1 || true)
cd "$ORIGINAL_DIR"

if echo "$output" | grep -A 1 "Checking: invalid.conf" | grep -q "Invalid HOCON format"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Invalid HOCON format detected${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Invalid HOCON format detected${NC}"
    echo -e "  ${RED}✗ FAILED${NC}\n"
fi

# Test 5: Empty config should have all keys missing
cd "$TEST_CONFIGS_DIR"
output=$("$COMPARE_SCRIPT" 2>&1 || true)
cd "$ORIGINAL_DIR"

if echo "$output" | grep -A 1 "Checking: empty.conf" | grep -q "Missing 14 key"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Empty config has all keys missing${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Empty config has all keys missing${NC}"
    echo -e "  ${RED}✗ FAILED${NC}\n"
fi

# Test 6: Summary statistics are correct
echo -e "${BLUE}--- Summary Statistics Tests ---${NC}\n"

cd "$TEST_CONFIGS_DIR"
output=$("$COMPARE_SCRIPT" 2>&1 || true)
cd "$ORIGINAL_DIR"

# Should check 4 files (complete, partial, minimal, empty - invalid is skipped)
if echo "$output" | grep -q "Total files checked: 4"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct number of files checked${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct number of files checked${NC}"
    echo -e "  ${RED}✗ FAILED - Expected 4 files checked${NC}\n"
fi

# Test 7: Files with missing keys count
if echo "$output" | grep -q "Files with missing keys:.*3"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct count of files with missing keys${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct count of files with missing keys${NC}"
    echo -e "  ${RED}✗ FAILED - Expected 3 files with missing keys${NC}\n"
fi

# Test 8: Files with all keys count
if echo "$output" | grep -q "Files with all keys:.*1"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct count of files with all keys${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct count of files with all keys${NC}"
    echo -e "  ${RED}✗ FAILED - Expected 1 file with all keys${NC}\n"
fi

# Test 9: Script finds correct number of keys in default.conf
cd "$TEST_CONFIGS_DIR"
output=$("$COMPARE_SCRIPT" 2>&1 || true)
cd "$ORIGINAL_DIR"

if echo "$output" | grep -q "Found.*14.*keys in default.conf"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct number of keys extracted from default.conf${NC}"
    echo -e "  ${GREEN}✓ PASSED${NC}\n"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: Correct number of keys extracted from default.conf${NC}"
    echo -e "  ${RED}✗ FAILED - Expected 14 keys${NC}\n"
fi

# Final summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Results Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total tests run:    $TESTS_RUN"
echo -e "${GREEN}Tests passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Tests failed:       $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
