#!/bin/bash

#
# 01-dotfiles.sh
#
# This script manages dotfile symlinks using the 'stow' utility.
# It iterates through the packages in the '$HOME/dotfiles' directory and
# uses 'stow' to create symlinks in the HOME directory.
#

# --- Safety Settings ---
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Logger Import ---
source ./shared/logger.sh

# --- Configuration ---
APP_NAME="Dotfiles Configuration"
LOG_DISPLAY_NAME="Dotfiles Symlink Setup"

#
# log_error_and_exit(message)
#
# This function is used to log a fatal error message and exit the script.
#
log_error_and_exit() {
    local message="$1"
    echo "[FATAL: $APP_NAME] $message" >&2
    exit 1
}

# 1. Ensure 'stow' is installed.
if ! command -v stow &> /dev/null; then
    log_error_and_exit "Dependency missing: 'stow' utility is required for dotfiles management."
fi

# 2. Check if the dotfiles source directory exists.
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error_and_exit "Dotfiles source directory not found at $DOTFILES_DIR."
fi

log_boot_start "Loading dotfiles from $DOTFILES_DIR..."
log_boot_ok

# 3. Change to the HOME directory.
pushd "$HOME" > /dev/null

# 4. Loop through each subdirectory (package) in dotfiles and run stow.
for dir in dotfiles/*/; do
    if [ -d "$dir" ]; then
        PACKAGE_NAME=$(basename "$dir")
        stow --target="$HOME" --restow --adopt -d dotfiles "$PACKAGE_NAME" || log_error_and_exit "Failed to stow/adopt package: $PACKAGE_NAME."
    fi
done

# 5. Clean up the dotfiles source directory after 'stow --adopt'.
# The '--adopt' flag may have moved local files into the dotfiles directory.
# 'git restore' discards those changes, reverting the directory to its clean state from the repo.
log_boot_start "Cleaning up dotfiles source directory..."
pushd "$DOTFILES_DIR" > /dev/null || log_error_and_exit "Failed to change to dotfiles directory for cleanup."
git restore .
popd > /dev/null || log_error_and_exit "Failed to return from dotfiles directory."
log_boot_ok


# 6. Return to the previous directory.
popd > /dev/null || log_error_and_exit "Failed to return from HOME directory."

# --- Success ---
exit 0