#!/bin/bash

#
# run_scripts.sh
#
# This script coordinates the execution of post-installation scripts.
# It iterates through all '.sh' files in the 'scripts/run_scripts' directory,
# extracts a display name from each script, and executes them in order.
#

# --- Logger Import ---
source ./shared/logger.sh

# --- Configuration ---
POST_INSTALL_DIR="./scripts/run_scripts"

# --- Main Logic ---
log_header_h1 "Post-Installation Script Execution as ($(whoami))"
log_boot_start "Checking post-installation directory ($POST_INSTALL_DIR)..."

if [[ ! -d "$POST_INSTALL_DIR" ]]; then
    log_boot_failure "Required directory is missing. Skipping this phase."
else
    log_boot_ok
    log_separator

    # Loop through each script in the post-install directory, sorted alphabetically.
    for SCRIPT in "$POST_INSTALL_DIR"/*.sh; do
        if [[ ! -f "$SCRIPT" ]]; then continue; fi

        # Extract a descriptive display name from the script file.
        # This is used for a cleaner log message than the filename.
        FALLBACK_NAME=$(basename "$SCRIPT" ".sh")
        DISPLAY_NAME=$(grep '^LOG_DISPLAY_NAME=' "$SCRIPT" | head -n 1 | cut -d'=' -f2- | tr -d '"' | xargs)
        LOG_NAME_TO_USE="${DISPLAY_NAME:-$FALLBACK_NAME}"

        log_boot_start "Found post-install script: $SCRIPT"
        log_boot_ok
        log_sub_boot_start "Executing post-install script($SCRIPT): $LOG_NAME_TO_USE..."

        if [[ ! -x "$SCRIPT" ]]; then
            log_boot_failure "Script lacks executable permissions."
            echo -e "${INDENT}${INDENT}${ORANGE}Error Detail: Post-install script not executable ($SCRIPT). Please run: chmod +x $SCRIPT${NC}"
            continue
        fi

        # Execute the script silently, capturing only stderr for potential failure messages.
        ERROR_OUTPUT=$(bash "$SCRIPT" 2>&1 >/dev/null)
        EXIT_CODE=$?

        if [ $EXIT_CODE -ne 0 ]; then
            # Extract a custom FATAL error message from the sub-script's output.
            CLEAN_ERROR=$(echo "$ERROR_OUTPUT" | grep 'FATAL:' | head -n 1 | xargs)
            if [ -z "$CLEAN_ERROR" ]; then
                 CLEAN_ERROR="Script failed with exit code $EXIT_CODE."
            fi
            log_boot_failure "$CLEAN_ERROR"
        else
            log_boot_success
        fi
    done

    # --- Finalization ---
    log_header_h2 "Finalization"
    log_boot_start "Post-installation scripts processing finished"
    log_boot_ok
fi