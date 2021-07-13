#!/bin/bash

#=========================
# Install Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
#=========================

# Key packages
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Download key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Register key
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install
sudo apt-get update
sudo apt-get install \
     docker-ce \
     docker-ce-cli \
     containerd.io

# Verify
sudo docker run hello-world

#======================
# Install Singularity
# https://sylabs.io/guides/3.0/user-guide/installation.html
#======================

sudo apt-get update
sudo apt-get -y install \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    pkg-config

#======================
# This community maintained package
# is out of date and did not work
# with Docker containers (but it
# did seem to install OK).
#======================

# Download key
#wget -O- http://neuro.debian.net/lists/focal.us-nh.libre | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list

# Register key
#sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9

# Install
#sudo apt-get update
#sudo apt-get install -y singularity-container

#=======================
# Sigularity (more up-to-date)
# https://sylabs.io/guides/3.7/user-guide/quick_start.html#quick-installation-steps
#=======================

sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# Confirmed Go is not present on Ubuntu20 minimal.

# Download and install Go
export VERSION=1.16.5 OS=linux ARCH=amd64 && \  # Replace the values as needed
  wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \ # Downloads the required Go package
  sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \ # Extracts the archive
  rm go$VERSION.$OS-$ARCH.tar.gz    # Deletes the ``tar`` file

echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc && \
    source ~/.bashrc

# Download Singularity release
# 3.7.4 fixes a security issue: https://github.com/hpcng/singularity/releases
export VERSION=3.7.4 && # adjust this as necessary \
    wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity

# Compile and install Singularity
./mconfig && \
    make -C builddir && \
    sudo make -C builddir install

# Verify
singularity --version

