#!/bin/bash

# Check if Metals is installed
if ! command -v metals &> /dev/null; then
    echo "WARNING: Metals is not installed or not in PATH"
    echo "Please install Metals first:"
    echo "  cs install metals"
    echo ""
    echo "Or visit: https://scalameta.org/metals/"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "\K[^"]*')
echo "INFO: Found Java version: $JAVA_VERSION"

# Check if Java version is 11 or 17
if ! echo "$JAVA_VERSION" | grep -E '^(11|17)' > /dev/null; then
    echo "WARNING: Java version should be 11 or 17 (found: $JAVA_VERSION)"
fi

# Verify Metals version
METALS_VERSION=$(metals --version 2>&1)
echo "INFO: Metals version: $METALS_VERSION"

exit 0
