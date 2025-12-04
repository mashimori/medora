#!/bin/bash

#
# check-version.sh
#
# This script verifies that the system is running a compatible OS version.
# It checks the OS ID, version ID, and architecture.
#
# NOTE: This script is sourced by 'install.sh' and uses the logger functions
#       without importing the logger library directly.
#

# --- Configuration ---
# Define the required OS and architecture.
#
# NOTE: The REQUIRED_VERSION_ID is hardcoded to "43". This script will fail
#       on any other version of Fedora.
#
REQUIRED_ID="fedora"
REQUIRED_VERSION_ID="43"
REQUIRED_ARCH="x86_64"

log_header_h1 "SYSTEM COMPATIBILITY CHECK"

# 1. Check for the /etc/os-release file.
log_boot_start "Checking OS release file (/etc/os-release)..."
if [ ! -f /etc/os-release ]; then
    log_boot_failure "/etc/os-release file not found."
    log_separator
    log_boot_start "Installation stopped"
    log_boot_failure "Fatal system error"
    exit 1
fi
log_boot_ok

# Source the os-release file to get OS variables.
. /etc/os-release

# 2. Check the OS ID and version.
log_boot_start "Verifying OS ID ($ID) and Version ($VERSION_ID)..."

if [ "$ID" != "$REQUIRED_ID" ] || [ "$VERSION_ID" != "$REQUIRED_VERSION_ID" ]; then
    log_boot_failure "OS requirement not met"
    echo -e "${INDENT}${INDENT}${ORANGE}Error Detail: Current: $ID $VERSION_ID. Expected: $REQUIRED_ID $REQUIRED_VERSION_ID.${NC}"
    log_separator
    log_boot_start "Installation stopped"
    log_boot_failure "Incompatible OS"
    exit 1
fi
log_boot_ok

# 3. Check the architecture.
ARCH=$(uname -m)
log_boot_start "Verifying Architecture ($ARCH)..."

if [ "$ARCH" != "$REQUIRED_ARCH" ]; then
    log_boot_failure "Unsupported architecture"
    echo -e "${INDENT}${INDENT}${ORANGE}Error Detail: Current: $ARCH. Expected: $REQUIRED_ARCH.${NC}"
    log_separator
    log_boot_start "Installation stopped"
    log_boot_failure "Incompatible CPU architecture"
    exit 1
fi
log_boot_ok

# --- Finalization ---
log_header_h2 "Finalization"
log_boot_start "System is compatible"
log_boot_ok