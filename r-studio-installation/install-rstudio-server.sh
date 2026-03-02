#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN}Dieses Skript muss als root ausgeführt werden. Bitte 'sudo' verwenden.${NC}"
    exit 1
fi

echo -e "${GREEN}Installiere gdebi...${NC}"
apt install gdebi
echo -e "${GREEN}Lade RStudio Server herunter...${NC}"
wget https://s3.amazonaws.com/rstudio-ide-build/server/bionic/arm64/rstudio-server-2022.11.0-daily-164-arm64.deb
echo -e "${GREEN}Installiere RStudio Server...${NC}"
gdebi rstudio-server-2022.11.0-daily-164-arm64.deb
echo -e "${GREEN}Bereinige Installationsdateien...${NC}"
rm rstudio-server-2022.11.0-daily-164-arm64.deb