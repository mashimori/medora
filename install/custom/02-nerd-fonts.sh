#!/bin/bash

#
# 02-nerd-fonts.sh
#
# Installation script for Nerd Fonts.
#

# --- Safety Settings ---
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
APP_NAME="Nerd Fonts Installer"

# List of fonts to download (ZIP file name only)
# Names must match the ZIP file names in the official Nerd Fonts repository.
FONT_LIST=(
    "JetBrainsMono"
    "CascadiaCode"
    "Hack"
)

# Target directory for user fonts
FONT_DIR="$HOME/.local/share/fonts"

# Base URL to download the ZIP files (assuming the latest release from the main repo)
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

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

# 1. Check for required dependencies.
echo "Checking required dependencies (curl, unzip)..."
if ! command -v curl &> /dev/null; then
    log_error "Missing required dependency: 'curl'."
    exit $EXIT_CODE_DEPS
fi
if ! command -v unzip &> /dev/null; then
    log_error "Missing required dependency: 'unzip'."
    exit $EXIT_CODE_DEPS
fi

# 2. Create the target directory.
if [ ! -d "$FONT_DIR" ]; then
    log_debug "Creating font directory at $FONT_DIR..."
    mkdir -p "$FONT_DIR"
fi

# 3. Main installation logic.

# Iterate through the list of fonts
for font_name in "${FONT_LIST[@]}"; do
    ZIP_FILE="${font_name}.zip"
    DOWNLOAD_URL="${BASE_URL}/${ZIP_FILE}"
    TEMP_PATH="/tmp/${ZIP_FILE}"
    FONT_SUBDIR="${FONT_DIR}/${font_name}NerdFont"

    # Downloading the font
    log_debug "Downloading ${font_name} from ${DOWNLOAD_URL}..."
    if ! curl -fLo "$TEMP_PATH" "$DOWNLOAD_URL"; then
        log_error "Error downloading file: ${DOWNLOAD_URL}."
        continue # Skip to the next font
    fi
    
    # Create subdirectory and extract
    log_debug "Extracting ${ZIP_FILE} to ${FONT_SUBDIR}..."
    mkdir -p "$FONT_SUBDIR"
    # Use -q (quiet) for unzip
    if ! unzip -o -q "$TEMP_PATH" -d "$FONT_SUBDIR"; then
        log_error "Error extracting file: ${TEMP_PATH}."
        rm -f "$TEMP_PATH"
        continue # Skip to the next font
    fi

    # Remove the temporary ZIP file
    log_debug "Removing temporary file ${TEMP_PATH}..."
    rm -f "$TEMP_PATH"

done

# 4. Refresh font cache.
log_debug "Refreshing font cache..."
if command -v fc-cache &> /dev/null; then
    fc-cache -fv
fi

# --- Finalization ---
log_debug "$APP_NAME installation finished successfully."
exit $EXIT_CODE_SUCCESS