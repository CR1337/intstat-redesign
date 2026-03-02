#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Prüfe Argument (Session-Name)
if [ -z "$1" ]; then
	echo -e "${GREEN}Bitte geben Sie einen Session-Namen an.\nAufruf: bash $0 <session-name>${NC}"
	exit 1
fi
SESSION_NAME="$1"

echo -e "${GREEN}Starte Installation in screen-Session: $SESSION_NAME${NC}"
screen -dmS "$SESSION_NAME" bash -c "\
	DIR=\"$(dirname \"$0\")\"; \
	echo -e '${GREEN}1. Installiere R...${NC}'; \
	sudo bash \"$DIR/install-r.sh\"; \
	echo -e '${GREEN}2. Installiere Shiny Server...${NC}'; \
	sudo bash \"$DIR/install-shiny-server.sh\"; \
	echo -e '${GREEN}3. Installiere RStudio Server...${NC}'; \
	sudo bash \"$DIR/install-rstudio-server.sh\"; \
	echo -e '${GREEN}Installation abgeschlossen!${NC}' \
"
echo -e "${GREEN}Die Installation läuft jetzt in der screen-Session '$SESSION_NAME'.\nMit 'screen -r $SESSION_NAME' können Sie den Fortschritt beobachten.${NC}"
