#!/bin/bash
# Setup script for mkdir alias that creates directory and changes into it
# Usage: source setup_mkdir_alias.sh

# Custom mkdir function that creates directory and changes into it
mkdir() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    
    # Use command to call the original mkdir to avoid recursion
    command mkdir -p "$1" && cd "$1"
}

echo "mkdir alias loaded! Now 'mkdir <dirname>' will create and cd into the directory."
echo "To make this permanent, add the mkdir function to your ~/.bashrc file."