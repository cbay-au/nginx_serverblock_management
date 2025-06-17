#!/bin/bash

# Nginx Server Block Management Script
# This script manages server blocks on an Nginx web server
# All operations require sudo privileges

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

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

# Function to print success messages
print_success() {
    print_color "$GREEN" "SUCCESS: $1"
}

# Function to print info messages
print_info() {
    print_color "$BLUE" "INFO: $1"
}

# Function to print warning messages
print_warning() {
    print_color "$YELLOW" "WARNING: $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check if nginx is installed
check_nginx() {
    if ! command -v nginx &> /dev/null; then
        print_error "Nginx is not installed. Please install nginx first."
        exit 1
    fi
}

# Function to check if certbot is installed
check_certbot() {
    if ! command -v certbot &> /dev/null; then
        print_warning "Certbot is not installed. Installing certbot..."
        apt update
        apt install -y certbot python3-certbot-nginx
        print_success "Certbot installed successfully"
    fi
}

# Function to validate domain name
validate_domain() {
    local domain=$1
    # Basic domain validation regex
    if [[ ! $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        print_error "Invalid domain name format: $domain"
        return 1
    fi
    return 0
}

# Function to list existing server blocks
list_server_blocks() {
    print_info "Listing existing server blocks..."
    echo
    
    # Get unique domain names from nginx configuration
    local domains
    domains=$(nginx -T 2>/dev/null | grep -E "^\s*server_name" | sed -E 's/.*server_name\s+([^;]+);.*/\1/g' | tr ' ' '\n' | grep -v '^$' | sort -u)
    
    if [[ -z "$domains" ]]; then
        print_warning "No server blocks found"
        return
    fi
    
    print_success "Found the following domains:"
    local count=1
    while IFS= read -r domain; do
        # Skip default server names and wildcards
        if [[ "$domain" != "_" && "$domain" != "default_server" && "$domain" != "localhost" ]]; then
            echo "  $count. $domain"
            ((count++))
        fi
    done <<< "$domains"
}

# Function to create directory structure for new domain
create_domain_directory() {
    local domain=$1
    
    print_info "Creating directory structure for $domain..."
    
    # Create web root directory
    mkdir -p "/var/www/$domain/html"
    
    # Set ownership to current user (or www-data if running as root)
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown -R "$SUDO_USER:$SUDO_USER" "/var/www/$domain/html"
    else
        chown -R www-data:www-data "/var/www/$domain/html"
    fi
    
    # Set proper permissions
    chmod -R 755 "/var/www/$domain"
    
    print_success "Directory structure created for $domain"
}

# Function to create index.html file
create_index_html() {
    local domain=$1
    local html_file="/var/www/$domain/html/index.html"
    
    print_info "Creating index.html for $domain..."
    
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
    <head>
        <title>Welcome to $domain!</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                background-color: #f4f4f4;
            }
            .container {
                background-color: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            h1 {
                color: #333;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Success! The $domain server block is working!</h1>
            <p>This is the default page for $domain. You can now customize this content.</p>
        </div>
    </body>
</html>
EOF
    
    print_success "Index.html created for $domain"
}

# Function to create nginx server block configuration
create_server_block() {
    local domain=$1
    local config_file="/etc/nginx/sites-available/$domain"
    
    print_info "Creating Nginx server block configuration for $domain..."
    
    cat > "$config_file" << EOF
server {
    listen 80;
    listen [::]:80;

    root /var/www/$domain/html;
    index index.html index.htm index.nginx-debian.html;

    server_name $domain www.$domain;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}
EOF
    
    print_success "Server block configuration created for $domain"
}

# Function to enable server block
enable_server_block() {
    local domain=$1
    local available_file="/etc/nginx/sites-available/$domain"
    local enabled_file="/etc/nginx/sites-enabled/$domain"
    
    print_info "Enabling server block for $domain..."
    
    # Create symbolic link
    if [[ ! -L "$enabled_file" ]]; then
        ln -s "$available_file" "$enabled_file"
        print_success "Server block enabled for $domain"
    else
        print_warning "Server block already enabled for $domain"
    fi
}

# Function to test nginx configuration
test_nginx_config() {
    print_info "Testing Nginx configuration..."
    
    if nginx -t; then
        print_success "Nginx configuration test passed"
        return 0
    else
        print_error "Nginx configuration test failed"
        return 1
    fi
}

# Function to reload nginx
reload_nginx() {
    print_info "Reloading Nginx..."
    
    if systemctl reload nginx; then
        print_success "Nginx reloaded successfully"
    else
        print_error "Failed to reload Nginx"
        return 1
    fi
}

# Function to obtain SSL certificate
obtain_ssl_certificate() {
    local domain=$1
    
    print_info "Obtaining SSL certificate for $domain..."
    
    # Check if certbot is available
    check_certbot
    
    # Obtain certificate
    if certbot --nginx -d "$domain" -d "www.$domain" --non-interactive --agree-tos --email "admin@$domain" --redirect; then
        print_success "SSL certificate obtained and configured for $domain"
    else
        print_error "Failed to obtain SSL certificate for $domain"
        print_warning "You may need to configure DNS records first"
        return 1
    fi
}

# Function to add new server block
add_server_block() {
    local domain
    
    echo
    print_info "Adding new server block..."
    
    # Get domain name from user
    while true; do
        read -p "Enter the domain name (e.g., example.com): " domain
        domain=$(echo "$domain" | tr '[:upper:]' '[:lower:]' | xargs)  # Convert to lowercase and trim
        
        if [[ -z "$domain" ]]; then
            print_error "Domain name cannot be empty"
            continue
        fi
        
        if validate_domain "$domain"; then
            break
        fi
    done
    
    # Check if server block already exists
    if [[ -f "/etc/nginx/sites-available/$domain" ]]; then
        print_error "Server block for $domain already exists"
        return 1
    fi
    
    print_info "Setting up server block for: $domain"
    
    # Create directory structure
    create_domain_directory "$domain"
    
    # Create index.html
    create_index_html "$domain"
    
    # Create server block configuration
    create_server_block "$domain"
    
    # Enable server block
    enable_server_block "$domain"
    
    # Test nginx configuration
    if ! test_nginx_config; then
        print_error "Nginx configuration test failed. Rolling back changes..."
        # Cleanup on failure
        rm -f "/etc/nginx/sites-enabled/$domain"
        rm -f "/etc/nginx/sites-available/$domain"
        rm -rf "/var/www/$domain"
        return 1
    fi
    
    # Reload nginx
    if ! reload_nginx; then
        return 1
    fi
    
    print_success "Server block created successfully for $domain"
    
    # Ask about SSL certificate
    echo
    read -p "Would you like to obtain an SSL certificate for $domain? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        obtain_ssl_certificate "$domain"
    fi
}

# Function to get list of available domains for modification
get_available_domains() {
    local domains
    domains=$(nginx -T 2>/dev/null | grep -E "^\s*server_name" | sed -E 's/.*server_name\s+([^;]+);.*/\1/g' | tr ' ' '\n' | grep -v '^$' | sort -u)
    
    local filtered_domains=()
    while IFS= read -r domain; do
        if [[ "$domain" != "_" && "$domain" != "default_server" && "$domain" != "localhost" ]]; then
            filtered_domains+=("$domain")
        fi
    done <<< "$domains"
    
    printf '%s\n' "${filtered_domains[@]}"
}

# Function to modify HTML files
modify_html_files() {
    echo
    print_info "Modifying HTML files for server blocks..."
    
    # Get available domains
    local domains
    readarray -t domains < <(get_available_domains)
    
    if [[ ${#domains[@]} -eq 0 ]]; then
        print_warning "No server blocks found to modify"
        return
    fi
    
    # Display available domains
    print_info "Available server blocks:"
    for i in "${!domains[@]}"; do
        echo "  $((i+1)). ${domains[i]}"
    done
    
    # Get user selection
    echo
    read -p "Enter the numbers of domains to modify (comma-separated, e.g., 1,3,5): " selection
    
    # Parse selection
    IFS=',' read -ra selected_indices <<< "$selection"
    local selected_domains=()
    
    for index in "${selected_indices[@]}"; do
        index=$(echo "$index" | xargs)  # Trim whitespace
        if [[ "$index" =~ ^[0-9]+$ ]] && [[ $index -ge 1 ]] && [[ $index -le ${#domains[@]} ]]; then
            selected_domains+=("${domains[$((index-1))]}")
        else
            print_warning "Invalid selection: $index"
        fi
    done
    
    if [[ ${#selected_domains[@]} -eq 0 ]]; then
        print_error "No valid domains selected"
        return
    fi
    
    # Get HTML file path
    echo
    read -p "Enter the path to the HTML file to use: " html_file_path
    
    if [[ ! -f "$html_file_path" ]]; then
        print_error "HTML file not found: $html_file_path"
        return
    fi
    
    # Copy HTML file to selected domains
    for domain in "${selected_domains[@]}"; do
        local target_dir="/var/www/$domain/html"
        if [[ -d "$target_dir" ]]; then
            print_info "Copying HTML file to $domain..."
            cp "$html_file_path" "$target_dir/index.html"
            
            # Set proper ownership and permissions
            if [[ -n "${SUDO_USER:-}" ]]; then
                chown "$SUDO_USER:$SUDO_USER" "$target_dir/index.html"
            else
                chown www-data:www-data "$target_dir/index.html"
            fi
            chmod 644 "$target_dir/index.html"
            
            print_success "HTML file updated for $domain"
        else
            print_warning "Web directory not found for $domain: $target_dir"
        fi
    done
    
    print_success "HTML files updated successfully"
}

# Function to display main menu
show_menu() {
    echo
    print_color "$BLUE" "=================================="
    print_color "$BLUE" "  Nginx Server Block Manager"
    print_color "$BLUE" "=================================="
    echo
    echo "1. List the domain names of existing server blocks"
    echo "2. Add a server block for a new domain name & add SSL cert"
    echo "3. Modify the HTML file for one or more server blocks"
    echo "4. Exit"
    echo
}

# Main function
main() {
    # Check if running as root
    check_root
    
    # Check if nginx is installed
    check_nginx
    
    while true; do
        show_menu
        read -p "Please select an option (1-4): " choice
        
        case $choice in
            1)
                list_server_blocks
                ;;
            2)
                add_server_block
                ;;
            3)
                modify_html_files
                ;;
            4)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-4."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Trap to handle script interruption
trap 'print_warning "Script interrupted by user"; exit 130' INT

# Run main function
main "$@"