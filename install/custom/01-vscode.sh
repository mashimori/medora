#!/bin/bash

#
# 01-vscode.sh
#
# This script installs Visual Studio Code on Fedora/RHEL/CentOS.
# It adds the Microsoft repository and installs the 'code' package.
#

# --- Configuration ---
APP_NAME="Visual Studio Code"

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

# 1. Check if Visual Studio Code is already installed.
if command -v code &> /dev/null; then
    log_debug "Visual Studio Code is already installed. Skipping installation."
    exit $EXIT_CODE_SKIPPED
fi

# 2. Add the Visual Studio Code repository.
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    # Import the Microsoft GPG key.
    log_debug "Importing Microsoft GPG key..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || {
        log_error "Failed to import Microsoft GPG key."
        exit 10
    }

    # Add the repository configuration.
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null || {
        log_error "Failed to create VS Code repository file."
        exit 11
    }
fi

# 3. Update metadata and install the package.
log_debug "Updating DNF metadata..."
sudo dnf check-update > /dev/null 2>&1
log_debug "Installing $APP_NAME package..."
sudo dnf install -y -q code || {
    log_error "DNF installation of 'code' package failed. Check package availability."
    exit 12
}

# --- Success ---
log_debug "$APP_NAME installation finished successfully."
exit 0