#!/bin/bash

#
# 01-vscode.sh
#
# This script installs Visual Studio Code on Fedora/RHEL/CentOS.
# It adds the Microsoft repository and installs the 'code' package.
#

# --- Configuration ---
APP_NAME="Visual Studio Code"
EXIT_CODE_SKIPPED=99 # Exit code for "already installed"

#
# log_error(message)
#
# This function is used to log a fatal error message to stderr.
# The parent script will capture this message and display it.
#
log_error() {
    echo "[FATAL: $APP_NAME] $1" >&2
}

# --- Main Installation Logic ---

# 1. Check if Visual Studio Code is already installed.
if command -v code &> /dev/null; then
    exit $EXIT_CODE_SKIPPED
fi

# 2. Add the Visual Studio Code repository.
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    # Import the Microsoft GPG key.
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
sudo dnf check-update > /dev/null 2>&1

sudo dnf install -y -q code || {
    log_error "DNF installation of 'code' package failed. Check package availability."
    exit 12
}

# --- Success ---
exit 0