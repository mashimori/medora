#!/bin/bash

#
# install_cargo.sh
#
# This script installs Rust crates from the 'install/cargo_packages.list' file
# using 'cargo install'.
#

# --- Logger Import ---
source ./shared/logger.sh

# --- Configuration ---
PACKAGE_FILE="./install/cargo_packages.list"
CARGO_LIST_INSTALLED_CMD="cargo install --list"
CARGO_INSTALL_CMD="cargo install --quiet"

# --- Main Logic ---
log_header_h1 "Rust Crate Installation (Cargo) as ($(whoami))"

# --- Configuration Verification ---
log_header_h2 "Configuration Verification"
log_boot_start "Checking package list file ($PACKAGE_FILE)..."
if [[ ! -f "$PACKAGE_FILE" ]]; then
    log_boot_failure "Required file is missing from current directory."
    exit 1
else
    log_boot_ok
fi

# Check for 'cargo' availability.
log_boot_start "Checking for Cargo command..."
if ! command -v cargo &> /dev/null; then
    log_boot_failure "Cargo command not found. Please ensure Rust is installed."
    exit 1
else
    log_boot_ok
fi

# --- Installation ---
log_header_h2 "Crate Installation Process"

# Loop through the package list and attempt installation.
while IFS= read -r CRATE || [[ -n "$CRATE" ]]; do

    CRATE=$(echo "$CRATE" | xargs)

    # Skip empty lines and comments.
    if [[ -z "$CRATE" ]]; then
        continue
    elif [[ "$CRATE" =~ ^# ]]; then
        log_boot_start "Skipping comment line: $CRATE..."
        log_boot_skipped_comment
        continue
    fi

    log_boot_start "Processing crate: $CRATE..."

    # 1. Check if the package is already installed.
    if $CARGO_LIST_INSTALLED_CMD 2>&1 | grep -q "^${CRATE}\s"; then
        log_boot_skipped
        continue
    fi

    # 2. Perform the installation.
    ERROR_OUTPUT=$( $CARGO_INSTALL_CMD "$CRATE" 2>&1)
    INSTALL_STATUS=$?

    if [ $INSTALL_STATUS -eq 0 ]; then
        log_boot_success
    else
        # Capture and clean the error message.
        CLEAN_ERROR=$(echo "$ERROR_OUTPUT" | head -n 1 | xargs)

        if [ -z "$CLEAN_ERROR" ]; then
             CLEAN_ERROR="Installation failed. Check network connection or crate name."
        fi

        log_boot_failure "$CLEAN_ERROR"
    fi

done < "$PACKAGE_FILE"

# --- Finalization ---
log_header_h2 "Finalization"
log_boot_start "Script execution complete"
log_boot_ok