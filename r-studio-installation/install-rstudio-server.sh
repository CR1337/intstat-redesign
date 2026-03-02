#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo'."
    exit 1
fi

apt install gdebi
wget https://s3.amazonaws.com/rstudio-ide-build/server/bionic/arm64/rstudio-server-2022.11.0-daily-164-arm64.deb
gdebi rstudio-server-2022.11.0-daily-164-arm64.deb
rm rstudio-server-2022.11.0-daily-164-arm64.deb