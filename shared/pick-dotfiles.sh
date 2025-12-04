#!/bin/bash

#
# pick-dotfiles.sh
#
# This script prompts the user to provide a git repository URL for their dotfiles.
# It then clones the repository to '$HOME/dotfiles'. If the directory already
# exists, the script will skip the cloning process.
#

# --- Logger Import ---
source ./shared/logger.sh

# --- Main Logic ---
log_header_h1 "DOTFILES REPOSITORY SETUP"

# Check if the dotfiles directory already exists.
if [ -d "$HOME/dotfiles" ]; then
    log_boot_start "Dotfiles directory already exists at $HOME/dotfiles. Skipping clone."
    log_boot_ok
    exit 0
fi

# Prompt the user to enter the dotfiles repository URL.
log_info "************************************************************"
log_info "* Please enter the path to your dotfiles git repository:"
log_info "* (e.g., http://domain.ext/username/dotfiles.git)"
log_info "* Use mine if you don't have your own: https://github.com/mashimori/dotfiles.git"
log_info "************************************************************"

log_prompt "Dotfiles Git Repository URL:"
read -rp "> " DOTFILES_REPO

# Validate the user input.
if [ -z "$DOTFILES_REPO" ]; then
    log_info "No repository URL provided. Exiting."
    exit 1
fi

log_boot_start "Provided repository URL: $DOTFILES_REPO"
log_boot_ok

# Clone the dotfiles repository.
log_boot_start "Cloning dotfiles repository..."
if git clone "$DOTFILES_REPO" "$HOME/dotfiles" >/dev/null 2>&1; then
    log_boot_ok
else
    log_boot_failure "Failed to clone repository from $DOTFILES_REPO. Exiting."
    exit 1
fi