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
PACKAGE_FILE="./install/dnf_default.list"
COPR_FILE="./install/dnf_copr.list"

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

log_boot_start "Checking COPR list file ($COPR_FILE)..."
if [[ ! -f "$COPR_FILE" ]]; then
    # Do not exit if COPR file is missing, just set a skip flag.
    log_boot_warning "Optional COPR file is missing. Skipping COPR setup."
    COPR_SKIP=true
else
    log_boot_ok
    COPR_SKIP=false
fi

# --- Installation ---
log_header_h2 "DEFAULT Repository Installation"

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

# --- COPR Repository Installation ---
if [ "$COPR_SKIP" = false ]; then
    log_header_h2 "COPR Repository Installation"

    if ! dnf repolist | grep -q 'copr' &> /dev/null; then
        log_boot_start "Installing 'dnf-plugins-core' (required for COPR support)..."
        sudo dnf install -y dnf-plugins-core &> /dev/null
        if [ $? -ne 0 ]; then
            log_boot_failure "Failed to install 'dnf-plugins-core'. Cannot proceed with COPR setup."
            COPR_SKIP=true
        else
            log_boot_success
        fi
    fi

    if [ "$COPR_SKIP" = false ]; then
        # Loop through the COPR list (only COPR name expected, e.g., 'dejan/lazygit')
        while IFS= read -r COPR_REPO || [[ -n "$COPR_REPO" ]]; do

            COPR_REPO=$(echo "$COPR_REPO" | xargs)

            # Skip empty lines and comments.
            if [[ -z "$COPR_REPO" ]]; then
                continue
            elif [[ "$COPR_REPO" =~ ^# ]]; then
                log_boot_start "Skipping comment line: $COPR_REPO..."
                log_boot_skipped_comment
                continue
            fi
            
            # Extract package name by removing everything up to and including the first slash (/).
            # Example: 'dejan/lazygit' becomes 'lazygit'.
            PACKAGE_TO_INSTALL=${COPR_REPO#*/}
            
            # Check if extraction was successful (i.e., if PACKAGE_TO_INSTALL is not empty)
            if [ -z "$PACKAGE_TO_INSTALL" ] || [ "$PACKAGE_TO_INSTALL" == "$COPR_REPO" ]; then
                log_boot_warning "Could not extract package name from '$COPR_REPO'. Skipping package installation."
                PACKAGE_TO_INSTALL="" # Ensure it's empty to skip install if logic fails
            fi

            # --- 1. Enable COPR Repository ---

            log_boot_start "Enabling COPR repository: $COPR_REPO..."
            
            # Check if the COPR repository is already enabled
            if dnf repolist | grep -q "copr:copr.fedorainfracloud.org:$COPR_REPO"; then
                 log_boot_skipped "COPR repository already enabled."
                 COPR_ENABLED=true
            else
                # Enable the COPR repository
                ERROR_OUTPUT=$(sudo dnf copr enable -y "$COPR_REPO" 2>&1)

                if [ $? -eq 0 ]; then
                    log_boot_ok
                    COPR_ENABLED=true
                else
                    CLEAN_ERROR=$(echo "$ERROR_OUTPUT" | grep 'Error:' | head -n 1 | sed 's/Error://g' | xargs)
                    if [ -z "$CLEAN_ERROR" ]; then
                         CLEAN_ERROR="COPR enablement failed. Check repository name or network."
                    fi
                    log_boot_failure "$CLEAN_ERROR"
                    COPR_ENABLED=false
                fi
            fi

            # --- 2. Install Associated Package(s) ---

            if [ "$COPR_ENABLED" = true ] && [ -n "$PACKAGE_TO_INSTALL" ]; then

                log_sub_boot_start "Installing associated package: $PACKAGE_TO_INSTALL..."

                # Check if the package is already installed
                if rpm -q "$PACKAGE_TO_INSTALL" &> /dev/null; then
                    log_boot_skipped "Package already installed."
                    continue
                fi

                # Perform the installation.
                ERROR_OUTPUT_INSTALL=$(sudo dnf install -y -q "$PACKAGE_TO_INSTALL" 2>&1)

                if [ $? -eq 0 ]; then
                    log_boot_success
                else
                    CLEAN_ERROR=$(echo "$ERROR_OUTPUT_INSTALL" | grep 'Error:' | head -n 1 | sed 's/Error://g' | xargs)
                    if [ -z "$CLEAN_ERROR" ]; then
                         CLEAN_ERROR="Associated package installation failed."
                    fi
                    log_boot_failure "$CLEAN_ERROR"
                fi
            fi

        done < "$COPR_FILE"
    fi
fi

# --- Finalization ---
log_header_h2 "Finalization"
log_boot_start "Script execution complete"
log_boot_ok