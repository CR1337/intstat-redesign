#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN}Dieses Skript muss als root ausgeführt werden. Bitte 'sudo' verwenden.${NC}"
    exit 1
fi

apt install -y gdebi-core
wget https://s3.amazonaws.com/rstudio-ide-build/server/jammy/arm64/rstudio-server-2026.01.0-392-arm64.deb
apt install -y libclang-14-dev libclang-common-14-dev libclang-dev libclang-rt-14-dev libclang1-14 libgc1 libllvm14 libobjc-12-dev libobjc4 libssl-dev
gdebi rstudio-server-2026.01.0-392-arm64.deb
