#!/bin/bash

#
# install.sh
#
# This script is the main orchestrator for the Fedora environment setup.
# It runs a series of sub-scripts to install packages and apply configurations.
# The script is designed to be run as a non-root user, and it will elevate
# to root privileges when necessary using 'sudo'.
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Display the intro banner.
bash ./shared/intro.sh

# --- Configuration ---
SHARED_DIR="./shared"
LOG_LIB="${SHARED_DIR}/logger.sh"

# --- Logger Validation ---
# The logger library is essential for providing formatted output.
# If the logger is not found, the script will exit with a fatal error.
if [ ! -f "$LOG_LIB" ]; then
    echo "FATAL ERROR: Logger library not found at $LOG_LIB. Cannot proceed."
    exit 1
fi
source "$LOG_LIB"

# --- Script Definitions ---
# Define paths to all the scripts that will be executed.
DNF_SCRIPT="./install/scripts/install_dnf.sh"
CARGO_SCRIPT="./install/scripts/install_cargo.sh"
CUSTOM_SCRIPT="./install/scripts/install_custom.sh"
POST_INSTALL_SCRIPT="./post_install/install.sh"
PICK_DOTFILES_SCRIPT="./shared/pick-dotfiles.sh"
CHECK_VERSION_SCRIPT="./shared/check-version.sh"

# --- User Identification ---
# Determine the real user who is running the script, even if 'sudo' or 'doas' is used.
# This is important for running commands as the correct user.
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
elif [ -n "$DOAS_USER" ]; then
    REAL_USER="$DOAS_USER"
    REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# Prevent the script from being run directly by the root user.
if [ "$REAL_USER" == "root" ]; then
    echo "This script should not be run by the root user directly. Please run as a normal user."
    exit 1
fi

# Function to run a command as the real user.
run_as_user(){
    sudo -u "$REAL_USER" -H "$@"
}

#--- Export Variables and Functions for Sub-Scripts ---
export REAL_USER
export REAL_HOME
export -f run_as_user

# --- Dotfiles Selection ---
# Allow the user to select which dotfiles to install.
run_as_user bash "$PICK_DOTFILES_SCRIPT"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    exit $EXIT_CODE
fi

# --- Privilege Check ---
log_header_h1 "PRIVILEGE CHECK"
log_boot_start "Verifying script is running with root privileges..."
if [ "$(id -u)" -eq 0 ]; then
    log_boot_ok
else
    log_boot_failure "No root privileges. CURRENT UID: $(id -u). Please run with 'sudo'."
    exit 1
fi

log_separator

# --- System Version Check ---
# Source the script to check the system version.
source "$CHECK_VERSION_SCRIPT"

# --- Main Installation Phases ---

log_header_h1 "SYSTEM SETUP: INSTALLATION ORCHESTRATOR"
log_header_h2 "Installation for User: $REAL_USER (Home: $REAL_HOME)"

# Phase 1: DNF Packages Installation
log_header_h2 "Phase 1/4: DNF System Packages Installation"
log_boot_start "Starting DNF script execution and validation ($DNF_SCRIPT)..."
log_separator

if [ ! -x "$DNF_SCRIPT" ]; then
    log_boot_failure "DNF Script not executable ($DNF_SCRIPT). Please run: chmod +x $DNF_SCRIPT"
    exit 1
fi

bash "$DNF_SCRIPT"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    exit $EXIT_CODE
fi

# Phase 2: Cargo Crates Installation
log_header_h2 "Phase 2/4: Cargo Rust Crates Installation"
log_boot_start "Starting Cargo script execution and validation ($CARGO_SCRIPT)..."
log_separator

if [ ! -x "$CARGO_SCRIPT" ]; then
    log_boot_failure "Cargo Script not executable ($CARGO_SCRIPT). Please run: chmod +x $CARGO_SCRIPT"
    exit 1
fi

run_as_user bash "$CARGO_SCRIPT"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    exit $EXIT_CODE
fi

# Phase 3: Custom Applications Installation
log_header_h2 "Phase 3/4: Custom Applications Installation"
log_boot_start "Starting Custom Apps script execution and validation ($CUSTOM_SCRIPT)..."
log_separator

if [ ! -x "$CUSTOM_SCRIPT" ]; then
    log_boot_failure "Custom Script not executable ($CUSTOM_SCRIPT). Please run: chmod +x $CUSTOM_SCRIPT"
    exit 1
fi

run_as_user bash "$CUSTOM_SCRIPT"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    exit $EXIT_CODE
fi

# Phase 4: Post-Installation Scripts
log_header_h2 "Phase 4/4: Post-Installation Script Execution (Configuration Scripts)"

if [ ! -x "$POST_INSTALL_SCRIPT" ]; then
    log_boot_failure "Post-Installation Script not executable ($POST_INSTALL_SCRIPT). Please run: chmod +x $POST_INSTALL_SCRIPT"
    exit 1
fi

run_as_user bash "$POST_INSTALL_SCRIPT"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    exit $EXIT_CODE
fi

# --- Finalization ---
log_header_h2 "TOTAL INSTALLATION SUMMARY"
log_boot_start "All installation phases completed successfully"
log_boot_ok