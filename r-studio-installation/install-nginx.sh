#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN}Dieses Skript muss als root ausgeführt werden. Bitte 'sudo' verwenden.${NC}"
    exit 1
fi

apt install nginx
cp ./nginx.conf /etc/nginx/sites-enabled/default

# Path to the Nginx service file
NGINX_SERVICE_FILE="/etc/systemd/system/multi-user.target.wants/nginx.service"

# Check if the file exists
if [ ! -f "$NGINX_SERVICE_FILE" ]; then
    echo "Nginx service file not found at $NGINX_SERVICE_FILE"
    echo "Is Nginx installed and enabled?"
    exit 1
fi

# Backup the original file
echo "Backing up the original Nginx service file..."
cp "$NGINX_SERVICE_FILE" "$NGINX_SERVICE_FILE.bak"

# Modify the After= line in the service file
echo "Modifying the Nginx service file..."
sed -i 's/After=network.target/After=network-online.target/g' "$NGINX_SERVICE_FILE"

# Reload the systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Restart Nginx to apply changes
echo "Restarting Nginx..."
systemctl restart nginx

echo "Done! Nginx should now start after the network is fully online."