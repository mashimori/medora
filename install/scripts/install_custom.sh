#!/bin/bash

#
# install_custom.sh
#
# This script executes custom installation scripts from the 'install/custom' directory.
# It iterates through all '.sh' files in the directory, extracts a display
# name from each script, and executes them in order.
#

# --- Logger Import ---
source ./shared/logger.sh

# --- Configuration ---
APPS_DIR="./install/custom"
SCRIPT_EXTENSION=".sh"
EXIT_CODE_SKIPPED=99 # Special exit code for skipped installations.

# --- Main Logic ---
log_header_h1 "Custom Application Installation as ($(whoami))"

# --- Configuration Verification ---
log_header_h2 "Configuration Verification"
log_boot_start "Checking applications directory ($APPS_DIR)..."
if [[ ! -d "$APPS_DIR" ]]; then
    log_boot_failure "Required directory is missing from current location."
    exit 1
else
    log_boot_ok
fi

# --- Installation ---
log_header_h2 "Application Execution Process"

# Loop through each script in the apps directory.
for APP_SCRIPT in "$APPS_DIR"/*"$SCRIPT_EXTENSION"; do

    # Check if any files were found.
    if [[ ! -f "$APP_SCRIPT" ]]; then
        continue
    fi

    # Extract a descriptive display name from the script file.
    FALLBACK_NAME=$(basename "$APP_SCRIPT" "$SCRIPT_EXTENSION")
    DESCRIPTIVE_NAME=$(grep '^APP_NAME=' "$APP_SCRIPT" | head -n 1 | cut -d'=' -f2- | tr -d '"' | xargs)
    LOG_NAME_TO_USE="${DESCRIPTIVE_NAME:-$FALLBACK_NAME}"

    # Ensure the script has executable permissions.
    if [[ ! -x "$APP_SCRIPT" ]]; then
        log_boot_start "Processing: $LOG_NAME_TO_USE (Permissions check)..."
        log_boot_failure "Script lacks executable permissions."
        continue
    fi

    log_boot_start "Found installation script: $APP_SCRIPT"
    log_boot_ok
    log_sub_boot_start "Installing: $LOG_NAME_TO_USE..."

    # Execute the script and capture both stdout and stderr.
    OUTPUT=$("$APP_SCRIPT" 2>&1)
    EXIT_CODE=$?

    # Handle the exit code of the script.
    if [ $EXIT_CODE -eq 0 ]; then
        log_boot_success
    elif [ $EXIT_CODE -eq $EXIT_CODE_SKIPPED ]; then
        log_boot_skipped
    else
        # Any other exit code is treated as a failure.
        # Try to find a custom FATAL error message in the script's output.
        CLEAN_ERROR=$(echo "$OUTPUT" | grep 'FATAL:' | head -n 1 | sed 's/.*\]//' | xargs)

        # Fallback to a generic error message if no FATAL message is found.
        if [ -z "$CLEAN_ERROR" ]; then
             CLEAN_ERROR="Script failed with exit code $EXIT_CODE."
        fi
        log_boot_failure "$CLEAN_ERROR"
    fi
done

# --- Finalization ---
log_header_h2 "Finalization"
log_boot_start "All custom applications processed"
log_boot_ok