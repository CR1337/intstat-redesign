#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starte vollständige Installation: R, Shiny Server und RStudio Server...${NC}"

DIR="$(dirname "$0")"

echo -e "${GREEN}1. Installiere R...${NC}"
sudo bash "$DIR/install-r.sh"

echo -e "${GREEN}2. Installiere Shiny Server...${NC}"
sudo bash "$DIR/install-shiny-server.sh"

echo -e "${GREEN}3. Installiere RStudio Server...${NC}"
sudo bash "$DIR/install-rstudio-server.sh"

echo -e "${GREEN}Installation abgeschlossen!${NC}"
