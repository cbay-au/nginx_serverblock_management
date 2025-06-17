#!/bin/bash

# Installation script for Nginx Server Block Manager
# This script sets up the environment and installs dependencies

set -euo pipefail

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

print_info() {
    print_color "$BLUE" "INFO: $1"
}

print_success() {
    print_color "$GREEN" "SUCCESS: $1"
}

print_warning() {
    print_color "$YELLOW" "WARNING: $1"
}

print_error() {
    print_color "$RED" "ERROR: $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This installation script must be run as root (use sudo)"
    exit 1
fi

print_info "Installing Nginx Server Block Manager..."

# Update package list
print_info "Updating package list..."
apt update

# Install Nginx if not present
if ! command -v nginx &> /dev/null; then
    print_info "Installing Nginx..."
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    print_success "Nginx installed and started"
else
    print_info "Nginx is already installed"
fi

# Install Certbot if not present
if ! command -v certbot &> /dev/null; then
    print_info "Installing Certbot for SSL certificates..."
    apt install -y certbot python3-certbot-nginx
    print_success "Certbot installed"
else
    print_info "Certbot is already installed"
fi

# Install other useful tools
print_info "Installing additional tools..."
apt install -y curl wget nano vim

# Set up firewall rules (if ufw is available)
if command -v ufw &> /dev/null; then
    print_info "Configuring firewall rules..."
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    print_success "Firewall rules configured"
fi

# Create backup directory
print_info "Creating backup directory..."
mkdir -p /etc/nginx/backups
print_success "Backup directory created"

# Set proper permissions for scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

print_success "Installation completed!"
echo
print_info "You can now run the Nginx Server Block Manager with:"
print_color "$GREEN" "  ./nginx_manager.sh"
echo
print_info "For documentation, see README.md"
print_warning "Remember to configure your DNS records before adding SSL certificates"