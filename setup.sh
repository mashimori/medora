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
rm -rf ~/.local/share/fedora
git clone https://github.com/mashimori/fedora.git ~/.local/share/fedora >/dev/null

# Run the installation script
echo "Running install script..."
bash ~/.local/share/fedora/install.sh