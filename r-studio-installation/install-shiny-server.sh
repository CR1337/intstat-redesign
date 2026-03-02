#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo'."
    exit 1
fi

# Define your R package repository
REPO="'http://cran.rstudio.com/'" # For R installed from a standard repository or compiled from CRAN

# Make sure the system dependencies are installed
apt install libcairo2-dev libxt-dev git cmake pandoc pandoc-citeproc

# Install required R packages as sudo
su - -c "R -e \"install.packages('Rcpp', repos=$REPO)\""
su - -c "R -e \"install.packages('later', repos=$REPO)\""
su - -c "R -e \"install.packages('fs', repos=$REPO)\""
su - -c "R -e \"install.packages('R6', repos=$REPO)\""
su - -c "R -e \"install.packages('Cairo', repos=$REPO)\""
su - -c "R -e \"install.packages('httpuv', repos=$REPO)\""
su - -c "R -e \"install.packages('mime', repos=$REPO)\""
su - -c "R -e \"install.packages('jsonlite', repos=$REPO)\""
su - -c "R -e \"install.packages('digest', repos=$REPO)\""
su - -c "R -e \"install.packages('htmltools', repos=$REPO)\""
su - -c "R -e \"install.packages('xtable', repos=$REPO)\""
su - -c "R -e \"install.packages('sourcetools', repos=$REPO)\""
su - -c "R -e \"install.packages('shiny', repos=$REPO)\""
su - -c "R -e \"install.packages('rmarkdown', repos=$REPO)\""


# Download the source code for the latest shiny-server release from GitHub
git clone --depth 1 --branch v1.5.19.995 https://github.com/rstudio/shiny-server.git

# Compile the source code
cd shiny-server
DIR=`pwd`
PATH=$DIR/bin:$PATH
mkdir tmp
cd tmp
PYTHON=`which python`
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../
make
mkdir ../build

# Modify some download links and SHASUMs for arm64 compatibility
sed -i '8s/.*/NODE_SHA256=5a6e818c302527a4b1cdf61d3188408c8a3e4a1bbca1e3f836c93ea8469826ce/' ../external/node/install-node.sh # SHAMSUM for node-v16.14.0-linux-arm64.tar.xz
sed -i 's/linux-x64.tar.xz/linux-arm64.tar.xz/' ../external/node/install-node.sh
sed -i 's/https:\/\/github.com\/jcheng5\/node-centos6\/releases\/download\//https:\/\/nodejs.org\/dist\//' ../external/node/install-node.sh
sed -i 's/sha512-3RAVyfbptsR6HOFA0BFNLyw8ZXXDRWf5P3tIslbNt12kTikaRWepRR9vLHMyibIZeNfScI9uGqcn1KfbIAeuXA==/sha512-ZwrJM2WaOJesJGZlejLqAiBAE6Ts2PZNk1pQ\/x1uTMsQw83BaXWShjqCbhh5bPQUNrlx2Ijz1dOr0hLmlkxKag==/' ../npm-shrinkwrap.json

# Install node for arm64 and rebuild node modules
(cd .. && ./external/node/install-node.sh)
(cd .. && ./bin/npm --python="${PYTHON}" install --no-optional)
(cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js --python="${PYTHON}" rebuild)

# Install shiny-server
make install

# Configure shiny-server
mkdir -p /etc/shiny-server
cp ../config/default.config /etc/shiny-server/shiny-server.conf
cp ../config/init.d/debian/shiny-server /etc/init.d/shiny-server
cd
rm -rf shiny-server
ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server
useradd -r -m shiny
mkdir -p /var/log/shiny-server
mkdir -p /srv/shiny-server
mkdir -p /var/lib/shiny-server
chown shiny /var/log/shiny-server
mkdir -p /etc/shiny-server

# Edit the shiny-server.service file
nano /lib/systemd/system/shiny-server.service
cp ./shiny-server.conf /lib/systemd/system/shiny-server.service

chown root:root /lib/systemd/system/shiny-server.service
chmod 644 /lib/systemd/system/shiny-server.service
systemctl daemon-reload
systemctl enable shiny-server
systemctl start shiny-server
ln -s -f /usr/bin/pandoc /usr/local/shiny-server/ext/pandoc/pandoc
ln -s -f /usr/bin/pandoc-citeproc /usr/local/shiny-server/ext/pandoc/pandoc-citeproc
ln -s /usr/local/shiny-server/samples/sample-apps /srv/shiny-server/sample-apps
ln -s /usr/local/shiny-server/samples/welcome.html /srv/shiny-server/index.html

# Set proper user permissions, I'm assuming your user is "pi", change it if it isn't
groupadd shiny-apps
usermod -aG shiny-apps pi
usermod -aG shiny-apps shiny
cd /srv/shiny-server
chown -R pi:shiny-apps .
chmod g+w .
chmod g+s .
cd