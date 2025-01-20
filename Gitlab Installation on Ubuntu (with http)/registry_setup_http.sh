#!/bin/bash

# Prompt user for registry port
read -p "Enter the port for GitLab registry (other than 5050): " registry_port

# Path to GitLab config
file_path="/etc/gitlab/gitlab.rb"

# Extract host/IP from external_url line
# 1. grep the line that starts with optional spaces, then `external_url 'http://`
# 2. cut by `'` to get the URL portion
# 3. remove `http://` prefix with sed
ip=$(grep -E "^[[:space:]]*external_url 'http://" "$file_path" \
    | head -n1 \
    | cut -d"'" -f2 \
    | sed -E 's|^http://||')

# Stop if no IP or host was found
if [ -z "$ip" ]; then
  echo "Failed to extract IP/host from $file_path."
  echo "Make sure the line looks like: external_url 'http://<IP_OR_HOST>'"
  exit 1
fi

# Insert lines below external_url (in reverse order so they appear top-down in the file)
sudo sed -i "/^[[:space:]]*external_url/a gitlab_rails['registry_external_url'] = 'http://${ip}:${registry_port}'" "$file_path"
sudo sed -i "/^[[:space:]]*external_url/a gitlab_rails['registry_storage_path'] = '/var/opt/gitlab/gitlab-rails/shared/registry'" "$file_path"
sudo sed -i "/^[[:space:]]*external_url/a gitlab_rails['registry_enabled'] = true" "$file_path"

# Apply changes
echo "Reconfiguring GitLab..."
sudo gitlab-ctl reconfigure
echo "GitLab registry setup completed successfully."

