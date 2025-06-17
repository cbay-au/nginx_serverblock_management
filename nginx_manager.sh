#!/bin/bash

# Nginx Server Block Manager - Sudo Wrapper
# This wrapper script automatically runs the main script with sudo privileges

set -euo pipefail

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print error messages
print_error() {
    print_color "$RED" "ERROR: $1" >&2
}

# Function to print info messages
print_info() {
    print_color "$BLUE" "INFO: $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/nginx_server_manager.sh"

# Check if the main script exists
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    print_error "Main script not found: $MAIN_SCRIPT"
    exit 1
fi

# Check if the main script is executable
if [[ ! -x "$MAIN_SCRIPT" ]]; then
    print_error "Main script is not executable: $MAIN_SCRIPT"
    print_info "Run: chmod +x $MAIN_SCRIPT"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    # Already running as root, execute the main script directly
    exec "$MAIN_SCRIPT" "$@"
else
    # Not running as root, check if sudo is available
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not available. Please run this script as root or install sudo."
        exit 1
    fi
    
    print_info "This script requires root privileges. Running with sudo..."
    print_info "You may be prompted for your password."
    echo
    
    # Execute the main script with sudo
    exec sudo "$MAIN_SCRIPT" "$@"
fi