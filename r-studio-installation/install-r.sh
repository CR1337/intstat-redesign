#!/bin/bash

# Farben für Echo-Nachrichten
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN}Dieses Skript muss als root ausgeführt werden. Bitte 'sudo' verwenden.${NC}"
    exit 1
fi

# Set the R version to install
R_VERSION=4.5.0
echo -e "${GREEN}Starte Installation von R Version $R_VERSION...${NC}"

echo -e "${GREEN}Installiere Systemabhängigkeiten...${NC}"
apt install -y g++ gcc gfortran libreadline-dev libx11-dev libxt-dev \
                    libpng-dev libjpeg-dev libcairo2-dev xvfb \
                    libbz2-dev libzstd-dev liblzma-dev libtiff5 \
                    libssh-dev libgit2-dev libcurl4-openssl-dev \
                    libblas-dev liblapack-dev libopenblas-base \
                    zlib1g-dev openjdk-11-jdk \
                    texinfo texlive texlive-fonts-extra \
                    screen wget libpcre2-dev make cmake

cd /usr/local/src
echo -e "${GREEN}Lade R-Quellen herunter...${NC}"
wget https://cran.rstudio.com/src/base/R-${R_VERSION:0:1}/R-$R_VERSION.tar.gz
su
echo -e "${GREEN}Entpacke R-Quellen...${NC}"
tar zxvf R-$R_VERSION.tar.gz
cd R-$R_VERSION
echo -e "${GREEN}Konfiguriere und kompiliere R...${NC}"
./configure --enable-R-shlib --with-blas --with-lapack #BLAS and LAPACK are optional
make
make install
cd ..
echo -e "${GREEN}Bereinige Installationsdateien...${NC}"
rm -rf R-$R_VERSION*
exit