#!/bin/bash

#
# docker-install.sh
#
# Custom installation script for Docker Engine on DNF-based systems.
#

# --- Safety Settings ---
set -e

# --- Configuration ---
APP_NAME="Docker Engine"

# --- Debug Flag ---
# Set INSTALL_DEBUG to 'true' to enable debug logging.
# Example usage: INSTALL_DEBUG=true ./docker-install.sh
INSTALL_DEBUG="${INSTALL_DEBUG:-false}" # Defaults to false if not set

# --- Exit Codes ---
EXIT_CODE_SUCCESS=0
EXIT_CODE_SKIPPED=99 # Standard exit code for skipped installation.
EXIT_CODE_DEPS=10    # Standard error code for missing dependencies.
EXIT_CODE_FATAL=100  # Standard error code for fatal errors.

#
# log_error(message)
#
# This function is used to log a fatal error message to stderr.
# The parent script will capture this message and display it.
#
log_error() {
    echo "[FATAL: $APP_NAME] $1" >&2
}

#
# log_debug(message)
#
# This function is used to log an informational/debug message to stdout.
# It only executes if the variable INSTALL_DEBUG is set to 'true'.
#
log_debug() {
    if [[ "$INSTALL_DEBUG" == "true" ]]; then
        echo "[DEBUG] $1"
    fi
}

# --- Main Installation Logic ---

log_debug "Starting installation and configuration of $APP_NAME. Debug mode is active."

# 1. Check if the application is already installed.
if command -v docker &> /dev/null; then
    log_debug "$APP_NAME is already installed. Checking configuration."
    # Although Docker is installed, we do not skip the script entirely
    # to ensure the user is in the 'docker' group and services are enabled.
    exit $EXIT_CODE_SKIPPED
fi

# 2. Installation steps go here.

# Add Docker repository
log_debug "Adding Docker repository..."
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

log_debug "Installing Docker packages (docker-ce, docker-ce-cli, containerd.io, plugins)..."
# Install Docker Engine and related packages
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check if the installation was successful
if ! command -v docker &> /dev/null; then
    log_error "Docker installation failed. Check DNF output above."
    exit $EXIT_CODE_FATAL
fi

log_debug "Enabling and starting Docker and ContainerD services..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service
sudo systemctl start containerd.service

log_debug "Creating 'docker' group (if it doesn't exist) and adding current user ($USER) to it..."
# The groupadd command will only work if the group doesn't exist. -aG works always.
sudo groupadd docker || true # '|| true' prevents the script from failing if the group already exists
sudo usermod -aG docker "$USER"

log_debug "Configuration complete. To apply group membership, log out and log back in, or run 'newgrp docker'."
log_debug "Running 'newgrp docker' now to attempt immediate activation (may fail in non-interactive shells)..."
# This command will change the group only for the current shell, so it may not have the desired effect in all contexts.
newgrp docker || log_debug "'newgrp docker' failed. You must manually log out/in or run 'newgrp docker' for group membership to take effect."

# --- Finalization ---
log_debug "$APP_NAME installed successfully."
exit $EXIT_CODE_SUCCESS