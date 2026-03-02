#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo'."
    exit 1
fi

# Set the R version to install
R_VERSION=4.5.0

apt install -y g++ gcc gfortran libreadline-dev libx11-dev libxt-dev \
                    libpng-dev libjpeg-dev libcairo2-dev xvfb \
                    libbz2-dev libzstd-dev liblzma-dev libtiff5 \
                    libssh-dev libgit2-dev libcurl4-openssl-dev \
                    libblas-dev liblapack-dev libopenblas-base \
                    zlib1g-dev openjdk-11-jdk \
                    texinfo texlive texlive-fonts-extra \
                    screen wget libpcre2-dev make cmake
cd /usr/local/src
wget https://cran.rstudio.com/src/base/R-${R_VERSION:0:1}/R-$R_VERSION.tar.gz
su
tar zxvf R-$R_VERSION.tar.gz
cd R-$R_VERSION
./configure --enable-R-shlib --with-blas --with-lapack #BLAS and LAPACK are optional
make
make install
cd ..
rm -rf R-$R_VERSION*
exit