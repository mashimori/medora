#!/bin/bash

#
# setup.sh 
#
# This script prepares the system for the installation of the Fedora environment.
# It updates the system, installs git, clones the repository, and runs the main installation script.
#

# Update the system and install git
echo "Updating system..."
sudo dnf update -y >/dev/null
echo "Installing git..."
sudo dnf install git -y >/dev/null

# Clone the repository
echo "Cloning repository..."
rm -rf ~/.local/share/medora
git clone https://github.com/mashimori/medora.git ~/.local/share/medora >/dev/null

# Navigate to the cloned directory and set execute permissions to all scripts
cd ~/.local/share/medora || { echo "Failed to navigate to the cloned repository."; exit 1; }
find . -type f -name "*.sh" -exec chmod +x {} \;

# Run the installation script
echo "Running install script..."
sudo bash ~/.local/share/medora/install.sh