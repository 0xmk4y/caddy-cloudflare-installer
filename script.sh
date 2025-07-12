set -e # Exit immediately if a command exits with a non-zero status.

# Install Go, Caddy, and xcaddy (Caddy builder) for Debian/Ubuntu-based systems
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https golang-go
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-xcaddy.list
sudo apt update
sudo apt install -y xcaddy

# Build Caddy with the Cloudflare DNS provider plugin
xcaddy build --with github.com/caddy-dns/cloudflare
sudo mv caddy /usr/local/bin/caddy
sudo chmod +x /usr/local/bin/caddy

# Create Caddy user and group for secure operation (before setting permissions)
sudo groupadd --system caddy || true # Add group if it doesn't exist
sudo useradd --system \
  --gid caddy \
  --create-home \
  --home-dir /var/lib/caddy \
  --shell /usr/sbin/nologin \
  --comment "Caddy web server" \
  caddy || true # Add user if it doesn't exist

# Create Caddy configuration directory and set permissions
sudo mkdir -p /etc/caddy
sudo chown -R caddy:caddy /etc/caddy

echo "" > /etc/caddy/Caddyfile
sudo chmod 644 /etc/caddy/Caddyfile

# Create and set permissions for Caddy's data and log directories
sudo mkdir -p /var/lib/caddy
sudo chown -R caddy:caddy /var/lib/caddy
sudo chmod 755 /var/lib/caddy

sudo mkdir -p /var/log/caddy
sudo chown -R caddy:caddy /var/log/caddy
sudo chmod 755 /var/log/caddy

# Write the systemd service file for Caddy
sudo bash -c 'cat > /etc/systemd/system/caddy.service' << 'EOF'
[Unit]
Description=Caddy Web Server
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=exec
User=caddy
Group=caddy
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start Caddy service
sudo systemctl daemon-reload
sudo systemctl enable caddy
#sudo systemctl start caddy