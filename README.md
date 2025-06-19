# Nginx Server Block Manager

A comprehensive bash script for managing Nginx server blocks on a Digital Ocean VPS or any Linux server running Nginx.

After git clone into local repo make sure permissions are setup vis:-

```
chmod +x nginx_manager.sh
chmod +x nginx_server_manager.sh
chmod +x install.sh
chmod +x demo.sh
chmod +x test_script.sh
```
Run using
``` ./nginx_manager.sh ```



## Features

- **List existing server blocks**: View all configured domain names
- **Add new server blocks**: Create complete server configurations with SSL certificates
- **Modify HTML content**: Update HTML files for one or more server blocks
- **Automatic SSL certificate management**: Uses Let's Encrypt via Certbot
- **Security hardened**: Includes security headers and proper file permissions
- **Error handling**: Comprehensive error checking and rollback capabilities
- **User-friendly interface**: Colored output and interactive menus

## Files

- `nginx_manager.sh` - Main wrapper script (run this one)
- `nginx_server_manager.sh` - Core functionality script
- `README.md` - This documentation file

## Prerequisites

- Ubuntu/Debian-based Linux system
- Nginx installed and running
- Root/sudo access
- Internet connection (for SSL certificates)

## Installation

1. Download the scripts to your server:
```bash
wget https://raw.githubusercontent.com//cbay-au/nginx_serverblock_management/refs/heads/main/nginx_manager.sh
wget https://raw.githubusercontent.com/cbay-au/nginx_serverblock_management/refs/heads/main/nginx_server_manager.sh
```

2. Make the scripts executable:
```bash
chmod +x nginx_manager.sh nginx_server_manager.sh
```

## Usage

Run the main wrapper script:
```bash
./nginx_manager.sh
```

The script will automatically request sudo privileges if needed.

## Menu Options

### 1. List Domain Names
Lists all domain names configured in existing Nginx server blocks.

**Example output:**
```
Found the following domains:
  1. example.com
  2. test.com
  3. mysite.org
```

### 2. Add Server Block
Creates a complete server block configuration for a new domain including:

- Web directory structure (`/var/www/domain/html/`)
- Sample HTML file
- Nginx server block configuration
- SSL certificate via Let's Encrypt
- Security headers
- Gzip compression

**Process:**
1. Enter domain name (e.g., `example.com`)
2. Script creates directory structure
3. Generates sample HTML file
4. Creates Nginx configuration
5. Tests configuration
6. Reloads Nginx
7. Optionally obtains SSL certificate

### 3. Modify HTML Files
Allows you to update the HTML content for one or more existing server blocks.

**Process:**
1. Lists available server blocks
2. Select which domains to update (comma-separated numbers)
3. Specify path to new HTML file
4. Script copies file to selected domains

### 4. Exit
Safely exits the script.

## Security Features

- **Input validation**: Domain names are validated using regex
- **Security headers**: Automatically adds security headers to server blocks
- **Proper permissions**: Sets correct file ownership and permissions
- **SSL certificates**: Automatic HTTPS configuration with Let's Encrypt
- **Configuration testing**: Tests Nginx config before applying changes
- **Rollback capability**: Automatically rolls back changes if configuration fails

## Directory Structure Created

For each domain, the script creates:
```
/var/www/domain.com/
└── html/
    └── index.html
```

## Nginx Configuration Template

Each server block includes:
- HTTP and HTTPS listeners
- Proper document root
- Security headers
- Gzip compression
- Error handling
- SSL configuration (after certificate installation)

## Error Handling

The script includes comprehensive error handling:
- Validates domain names
- Checks for existing configurations
- Tests Nginx configuration before applying
- Rolls back changes on failure
- Provides clear error messages

## Troubleshooting

### Common Issues

1. **Permission denied**: Make sure you're running with sudo privileges
2. **Nginx not found**: Install Nginx first: `sudo apt install nginx`
3. **Certbot not found**: Script will auto-install certbot when needed
4. **SSL certificate fails**: Ensure DNS records point to your server
5. **Configuration test fails**: Check Nginx error logs: `sudo nginx -t`

### Log Files

- Nginx error log: `/var/log/nginx/error.log`
- Nginx access log: `/var/log/nginx/access.log`
- Certbot logs: `/var/log/letsencrypt/`

## Advanced Usage

### Manual SSL Certificate Renewal
```bash
sudo certbot renew
```

### Check Nginx Configuration
```bash
sudo nginx -t
```

### Reload Nginx
```bash
sudo systemctl reload nginx
```

### View Server Block Configuration
```bash
sudo cat /etc/nginx/sites-available/domain.com
```

## Security Considerations

- Script requires root privileges for Nginx management
- SSL certificates are automatically configured with secure settings
- Security headers are added to prevent common attacks
- File permissions are set to prevent unauthorized access
- Input validation prevents injection attacks

## Compatibility

- Tested on Ubuntu 18.04, 20.04, 22.04
- Compatible with Debian-based systems
- Requires Nginx 1.14+
- Requires Bash 4.0+

## Contributing

Feel free to submit issues and enhancement requests!

## License

This script is provided as-is for educational and practical use. Use at your own risk and always test in a development environment first.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Nginx error logs
3. Ensure all prerequisites are met
4. Test with a simple domain first

---

**Note**: Always backup your Nginx configuration before making changes:
```bash
sudo cp -r /etc/nginx /etc/nginx.backup.$(date +%Y%m%d)
```
