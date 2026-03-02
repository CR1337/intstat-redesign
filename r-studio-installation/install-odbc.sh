#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN}Dieses Skript muss als root ausgeführt werden. Bitte 'sudo' verwenden.${NC}"
    exit 1
fi

apt upgrade -y
apt install -y unixodbc unixodbc-dev
apt install -y odbc-mariadb
cp ./odbc.ini /etc/odbc.ini
cp ./odbcinst.ini /etc/odbcinst.ini