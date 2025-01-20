#!/bin/bash

# Prompt to enter Cloud Machine IP
read -p "Enter the Cloud Machine IP: " cloudip

# Update system packages
echo "Updating system packages..."
sudo apt-get update

# Install required dependencies
echo "Installing required dependencies..."
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

# Install Postfix
echo "Installing Postfix..."
# Preselect 'Internet Site' option for Postfix if prompted
echo "postfix postfix/mailname string $cloudip" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
sudo apt-get install -y postfix

# Display Postfix status
echo "Checking Postfix status..."
sudo systemctl status postfix

# Add GitLab repository and install GitLab EE
echo "Adding GitLab repository and installing GitLab EE..."
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install -y gitlab-ee

# Configure GitLab external URL
echo "Configuring GitLab external URL..."
file_path="/etc/gitlab/gitlab.rb"
sudo sed -i "s|^external_url .*|external_url 'http://$cloudip'|g" "$file_path"

# Reconfigure GitLab
echo "Reconfiguring GitLab..."
sudo gitlab-ctl reconfigure

# Display initial root password
echo "Fetching initial root password..."
sudo cat /etc/gitlab/initial_root_password

echo "GitLab installation and configuration completed successfully."
