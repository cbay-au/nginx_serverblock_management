# Nginx Server Block Management Repository

## Purpose
This repository provides a comprehensive bash script solution for managing Nginx server blocks on Digital Ocean VPS or any Linux server. It offers an interactive menu system for creating, managing, and modifying Nginx server configurations with automatic SSL certificate management via Let's Encrypt.

## General Setup
- **Target Environment**: Ubuntu/Debian-based Linux systems with Nginx
- **Requirements**: Root/sudo access, internet connection for SSL certificates
- **Dependencies**: Nginx, Certbot (auto-installed if missing)
- **Installation**: Run `sudo ./install.sh` to set up environment and dependencies
- **Usage**: Execute `./nginx_manager.sh` for interactive menu system

## Repository Structure

### Core Scripts
- **`nginx_manager.sh`** - Main wrapper script that handles sudo privilege escalation and serves as the entry point
- **`nginx_server_manager.sh`** - Core functionality script containing all server block management features
- **`install.sh`** - Installation script that sets up Nginx, Certbot, and configures firewall rules

### Supporting Files
- **`demo.sh`** - Demonstration script showing menu system without requiring root privileges
- **`test_script.sh`** - Validation script for testing syntax and functionality of main scripts
- **`sample.html`** - Professional HTML template used for new server blocks and testing
- **`for_sale.html`** - Domain for sale page with contact information

### Documentation
- **`README.md`** - Comprehensive documentation with installation, usage, and troubleshooting
- **`PROJECT_SUMMARY.md`** - Detailed project overview and technical implementation details

### Configuration
- **`.openhands/`** - OpenHands configuration directory
  - **`microagents/repo.md`** - This repository summary file
  - **`trigger_this.md`** - Trigger configuration file

## Key Features
1. **Interactive Menu System** with 4 main options:
   - List existing server blocks
   - Add new server block with SSL certificate
   - Modify HTML files for existing server blocks
   - Exit

2. **Automated Server Block Creation**:
   - Domain validation and directory structure setup
   - Nginx configuration with security headers
   - SSL certificate installation via Let's Encrypt
   - Proper file permissions and ownership

3. **Security Features**:
   - Input validation and sanitization
   - Security headers (X-Frame-Options, X-XSS-Protection, etc.)
   - SSL certificate automation
   - Configuration testing before applying changes
   - Rollback capability on errors

4. **Error Handling**:
   - Comprehensive error checking with colored output
   - Automatic rollback on configuration failures
   - Clear error messages and warnings

## CI/CD Configuration
**No CI/CD pipelines configured** - This repository does not contain any GitHub Actions workflows, pre-commit hooks, or other automated testing/deployment configurations. The repository includes a manual test script (`test_script.sh`) for basic validation of script syntax and functionality.

## Technical Implementation
- **Language**: Bash scripting with strict error handling (`set -euo pipefail`)
- **Architecture**: Modular function-based design with separation of concerns
- **Security**: Root privilege validation, domain regex validation, secure file permissions
- **User Experience**: Color-coded output, interactive menus, comprehensive feedback