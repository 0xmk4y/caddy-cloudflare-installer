# Caddy with Cloudflare DNS Setup

> **Automated installation and configuration script for Caddy web server with Cloudflare DNS provider plugin**

This script automates the installation and setup of Caddy web server with the Cloudflare DNS provider plugin on Debian/Ubuntu-based systems. It handles the complete setup process including building Caddy with the plugin, creating system users, configuring directories, and setting up the systemd service.

## Features

- 🚀 **Automated Installation**: Complete hands-off setup of Caddy with Cloudflare DNS
- 🔒 **Security First**: Creates dedicated system user and follows security best practices
- 📦 **Custom Build**: Builds Caddy with Cloudflare DNS provider plugin using xcaddy
- 🔧 **Production Ready**: Includes systemd service configuration for production deployment
- 🛡️ **Secure Defaults**: Proper file permissions and service isolation

## Prerequisites

- Debian/Ubuntu-based Linux distribution
- Root or sudo access
- Internet connection for downloading packages

## Quick Start

```bash
# Download and run the script
curl -fsSL https://raw.githubusercontent.com/0xmk4y/caddy-cloudflare-setup/main/install.sh | sudo bash

# Or clone and run locally
git clone https://github.com/0xmk4y/caddy-cloudflare-setup.git
cd caddy-cloudflare-setup
sudo chmod +x install.sh
sudo ./install.sh
```

## What the Script Does

### 1. System Dependencies
- Updates package lists
- Installs essential packages: `debian-keyring`, `debian-archive-keyring`, `apt-transport-https`, `golang-go`
- Adds xcaddy repository and installs xcaddy (Caddy builder)

### 2. Caddy Installation
- Builds Caddy with Cloudflare DNS provider plugin using xcaddy
- Installs the custom Caddy binary to `/usr/local/bin/caddy`
- Sets proper executable permissions

### 3. User and Directory Setup
- Creates dedicated `caddy` system user and group
- Creates and configures directories:
  - `/etc/caddy` - Configuration directory
  - `/var/lib/caddy` - Data directory
  - `/var/log/caddy` - Log directory
- Sets appropriate ownership and permissions

### 4. Systemd Service
- Creates systemd service file at `/etc/systemd/system/caddy.service`
- Configures service with security features:
  - Runs as non-root `caddy` user
  - Private temporary directory
  - Protected system directories
  - Network binding capabilities
- Enables the service for automatic startup

## Configuration

### Caddyfile Setup

After installation, configure your Caddyfile at `/etc/caddy/Caddyfile`:

```caddy
# Basic example with Cloudflare DNS
example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    respond "Hello from Caddy with Cloudflare!"
}
```

### Environment Variables

Set up your Cloudflare API token:

```bash
# Create environment file
sudo mkdir -p /etc/caddy
echo "CLOUDFLARE_API_TOKEN=your_token_here" | sudo tee /etc/caddy/caddy.env

# Update systemd service to use environment file
sudo systemctl edit caddy
```

Add the following content:
```ini
[Service]
EnvironmentFile=/etc/caddy/caddy.env
```

## Usage

### Managing the Service

```bash
# Start Caddy
sudo systemctl start caddy

# Stop Caddy
sudo systemctl stop caddy

# Restart Caddy
sudo systemctl restart caddy

# Check status
sudo systemctl status caddy

# View logs
sudo journalctl -u caddy -f
```

### Reloading Configuration

```bash
# Reload configuration without downtime
sudo systemctl reload caddy

# Or use Caddy's built-in reload
sudo caddy reload --config /etc/caddy/Caddyfile
```

## Directory Structure

```
/etc/caddy/
├── Caddyfile          # Main configuration file
└── caddy.env          # Environment variables (optional)

/var/lib/caddy/        # Data directory (certificates, etc.)
/var/log/caddy/        # Log files
/usr/local/bin/caddy   # Caddy binary
```

## Security Notes

- The script creates a dedicated `caddy` system user for running the service
- Caddy runs with minimal privileges and uses `CAP_NET_BIND_SERVICE` for port binding
- File permissions are set to follow security best practices
- The service uses `PrivateTmp=true` and `ProtectSystem=full` for isolation

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're running the script with sudo privileges
2. **Service Won't Start**: Check the Caddyfile syntax with `caddy validate --config /etc/caddy/Caddyfile`
3. **DNS Challenges Failing**: Verify your Cloudflare API token has the correct permissions
4. **Port 80/443 Already in Use**: Stop other web servers (Apache, Nginx) first

### Useful Commands

```bash
# Test Caddyfile syntax
sudo caddy validate --config /etc/caddy/Caddyfile

# Check which process is using port 80/443
sudo lsof -i :80
sudo lsof -i :443

# View detailed service logs
sudo journalctl -u caddy --no-pager

# Check Caddy version and plugins
caddy version
caddy list-modules
```

## Cloudflare DNS Configuration

### API Token Setup

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Create a new token with the following permissions:
   - **Zone Resources**: Include → All zones
   - **Zone Permissions**: Zone:Read, DNS:Edit

### DNS Records

The Cloudflare DNS provider plugin can automatically create DNS records for ACME challenges, enabling automatic SSL certificate generation for domains behind Cloudflare.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Caddy](https://caddyserver.com/) - The amazing web server
- [xcaddy](https://github.com/caddyserver/xcaddy) - Caddy builder tool
- [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) - Cloudflare DNS provider plugin

## Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/0xmk4y/caddy-cloudflare-setup/issues) page
2. Create a new issue with detailed information about your problem
3. Include your OS version, error messages, and relevant logs

---

**⚠️ Important**: This script is designed for Debian/Ubuntu systems. For other distributions, you may need to modify the package installation commands accordingly.