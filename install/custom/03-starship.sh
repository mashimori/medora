#!/bin/bash

#
# 03-starship.sh
#
# Installation script for Starship (the minimal, blazing-fast, and infinitely customizable prompt).
#

# --- Safety Settings ---
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
APP_NAME="Starship Prompt"
INSTALL_URL="https://starship.rs/install.sh"
BINARY_NAME="starship"

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

# 1. Check if the application is already installed.
if command -v "$BINARY_NAME" &> /dev/null; then
    exit $EXIT_CODE_SKIPPED
fi

# 2. Check for required dependencies (curl).
echo "Checking required dependencies (curl)..."
if ! command -v curl &> /dev/null; then
    log_error "Missing required dependency: 'curl'. It is needed to download the installer."
    exit $EXIT_CODE_DEPS
fi

# 3. Create .local/bin if it doesn't exist.
if [ ! -d "$HOME/.local/bin" ]; then
    log_debug "Creating directory $HOME/.local/bin for Starship binary..."
    mkdir -p "$HOME/.local/bin"
fi

# 4. Installation steps.

# Execute the official Starship installation script.
# This pipe requires interaction with the shell (sh).
log_debug "Downloading and executing Starship installation script..."
if ! curl -sS "$INSTALL_URL" | sh -s -- -y -b "$HOME/.local/bin"; then
    log_error "Starship installation failed during the execution of the install script."
    exit $EXIT_CODE_FATAL
fi

# 5. Final installation check.
log_debug "Verifying Starship installation..."
if command -v "$BINARY_NAME"; then
    log_error "Starship installed successfully, but the binary was not found in PATH."
    exit $EXIT_CODE_FATAL
fi

# --- Finalization ---
log_debug "$APP_NAME installation finished successfully."
exit $EXIT_CODE_SUCCESS