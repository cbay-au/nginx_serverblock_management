#!/bin/bash

# Test script for Nginx Server Block Manager
# This script performs basic validation of the main scripts

set -eo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_test() {
    print_color "$BLUE" "TEST: $1"
}

print_pass() {
    print_color "$GREEN" "PASS: $1"
}

print_fail() {
    print_color "$RED" "FAIL: $1"
}

print_info() {
    print_color "$YELLOW" "INFO: $1"
}

# Test variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SCRIPT="$SCRIPT_DIR/nginx_manager.sh"
MAIN_SCRIPT="$SCRIPT_DIR/nginx_server_manager.sh"
README_FILE="$SCRIPT_DIR/README.md"

test_count=0
pass_count=0

run_test() {
    local test_name=$1
    local test_command=$2
    
    ((test_count++))
    print_test "$test_name"
    
    if eval "$test_command"; then
        print_pass "$test_name"
        ((pass_count++))
    else
        print_fail "$test_name"
    fi
    echo
}

# Test 1: Check if wrapper script exists
run_test "Wrapper script exists" "[[ -f '$WRAPPER_SCRIPT' ]]"

# Test 2: Check if main script exists
run_test "Main script exists" "[[ -f '$MAIN_SCRIPT' ]]"

# Test 3: Check if README exists
run_test "README file exists" "[[ -f '$README_FILE' ]]"

# Test 4: Check if wrapper script is executable
run_test "Wrapper script is executable" "[[ -x '$WRAPPER_SCRIPT' ]]"

# Test 5: Check if main script is executable
run_test "Main script is executable" "[[ -x '$MAIN_SCRIPT' ]]"

# Test 6: Check wrapper script syntax
run_test "Wrapper script syntax check" "bash -n '$WRAPPER_SCRIPT'"

# Test 7: Check main script syntax
run_test "Main script syntax check" "bash -n '$MAIN_SCRIPT'"

# Test 8: Check for required functions in main script
run_test "Main script contains required functions" "grep -q 'list_server_blocks\|add_server_block\|modify_html_files' '$MAIN_SCRIPT'"

# Test 9: Check for security features
run_test "Security headers present in script" "grep -q 'X-Frame-Options\|X-XSS-Protection\|X-Content-Type-Options' '$MAIN_SCRIPT'"

# Test 10: Check for SSL certificate functionality
run_test "SSL certificate functionality present" "grep -q 'certbot\|obtain_ssl_certificate' '$MAIN_SCRIPT'"

# Test 11: Check for input validation
run_test "Domain validation function present" "grep -q 'validate_domain' '$MAIN_SCRIPT'"

# Test 12: Check for error handling
run_test "Error handling present" "grep -q 'set -euo pipefail\|print_error' '$MAIN_SCRIPT'"

# Summary
echo "=================================="
print_color "$BLUE" "TEST SUMMARY"
echo "=================================="
print_info "Total tests: $test_count"
print_info "Passed: $pass_count"
print_info "Failed: $((test_count - pass_count))"

if [[ $pass_count -eq $test_count ]]; then
    print_color "$GREEN" "ALL TESTS PASSED! ✓"
    echo
    print_info "The scripts are ready to use. Run './nginx_manager.sh' to start."
else
    print_color "$RED" "SOME TESTS FAILED! ✗"
    echo
    print_info "Please check the failed tests and fix any issues before using the scripts."
fi

echo
print_info "Note: This test only validates script structure and syntax."
print_info "Full functionality testing requires a server with Nginx installed."