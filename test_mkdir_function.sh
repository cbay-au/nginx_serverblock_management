#!/bin/bash
# Test script for mkdir function - run this to test before adding to .bashrc

echo "Testing mkdir function syntax..."

# Version 1: Original function syntax
echo "Testing Version 1 (function syntax):"
mkdir() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}

# Test if it loads without errors
if declare -f mkdir > /dev/null; then
    echo "✓ Version 1 loaded successfully"
else
    echo "✗ Version 1 failed to load"
fi

# Unset the function to test next version
unset -f mkdir

# Version 2: Alternative function syntax
echo "Testing Version 2 (alternative syntax):"
function mkdir {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}

if declare -f mkdir > /dev/null; then
    echo "✓ Version 2 loaded successfully"
else
    echo "✗ Version 2 failed to load"
fi

unset -f mkdir

# Version 3: Safe version with different name
echo "Testing Version 3 (safe mkcd function):"
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}

if declare -f mkcd > /dev/null; then
    echo "✓ Version 3 (mkcd) loaded successfully"
    echo "You can use 'mkcd dirname' instead of overriding mkdir"
else
    echo "✗ Version 3 failed to load"
fi

echo ""
echo "Shell information:"
echo "SHELL: $SHELL"
echo "BASH_VERSION: $BASH_VERSION"
echo ""
echo "If all versions failed, there might be a shell compatibility issue."
echo "Try using the mkcd version (Version 3) as it's safer."