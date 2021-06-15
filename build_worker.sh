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

# Download key
wget -O- http://neuro.debian.net/lists/focal.us-nh.libre | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list

# Register key
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9

# Install
sudo apt-get update
sudo apt-get install -y singularity-container

# Verify
singularity --version

