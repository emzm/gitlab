#!/bin/bash

# Script to install the latest Docker on Ubuntu 22.04

# Update and remove old versions of Docker if they exist
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Install required packages
echo "Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
echo "Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package database with Docker packages
echo "Updating package database with Docker packages..."
sudo apt-get update -y

# Install Docker Engine, CLI, and Containerd
echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
echo "Verifying Docker installation..."
sudo docker --version
sudo docker-compose --version

# Enable and start Docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to Docker group (optional, requires logout/login to take effect)
echo "Adding current user to the Docker group..."
sudo usermod -aG docker $USER

echo "Docker installation completed successfully!"
echo "Logout and log back in for Docker group changes to take effect."

