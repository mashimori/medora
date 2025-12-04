#!/bin/bash

#
# install_dnf.sh
#
# This script installs packages from the 'install/dnf_packages.list' file
# using the 'dnf' package manager.
#

# --- Logger Import ---
source ./shared/logger.sh

# --- Configuration ---
PACKAGE_FILE="./install/dnf_packages.list"

# --- Main Logic ---
log_header_h1 "System Package Installation (dnf) as ($(whoami))"

# --- Configuration Verification ---
log_header_h2 "Configuration Verification"
log_boot_start "Checking package list file ($PACKAGE_FILE)..."
if [[ ! -f "$PACKAGE_FILE" ]]; then
    log_boot_failure "Required file is missing from current directory."
    exit 1
else
    log_boot_ok
fi

# --- Installation ---
log_header_h2 "Package Installation Process"

# Check for 'dnf' availability.
if ! command -v dnf &> /dev/null; then
    log_boot_failure "DNF command not found. This script requires a Fedora/RHEL system."
    exit 1
fi

# Loop through the package list and attempt installation.
while IFS= read -r PACKAGE || [[ -n "$PACKAGE" ]]; do

    PACKAGE=$(echo "$PACKAGE" | xargs)

    # Skip empty lines and comments.
    if [[ -z "$PACKAGE" ]]; then
        continue
    elif [[ "$PACKAGE" =~ ^# ]]; then
        log_boot_start "Skipping comment line: $PACKAGE..."
        log_boot_skipped_comment
        continue
    fi

    log_boot_start "Processing package: $PACKAGE..."

    # 1. Check if the package is already installed.
    if rpm -q "$PACKAGE" &> /dev/null; then
        log_boot_skipped
        continue
    fi

    # 2. Perform the installation.
    ERROR_OUTPUT=$(sudo dnf install -y -q "$PACKAGE" 2>&1)

    if [ $? -eq 0 ]; then
        log_boot_success
    else
        # Extract the relevant error message.
        CLEAN_ERROR=$(echo "$ERROR_OUTPUT" | grep 'Error:' | head -n 1 | sed 's/Error://g' | xargs)

        # Fallback to a generic error message.
        if [ -z "$CLEAN_ERROR" ]; then
             CLEAN_ERROR="Installation failed. Check system permissions or package name."
        fi
        log_boot_failure "$CLEAN_ERROR"
    fi

done < "$PACKAGE_FILE"

# --- Finalization ---
log_header_h2 "Finalization"
log_boot_start "Script execution complete"
log_boot_ok