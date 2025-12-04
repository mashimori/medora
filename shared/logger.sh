#!/bin/bash

#
# logger.sh
#
# This script provides a set of functions for logging messages to the console.
# It uses tput to colorize the output and provides different log levels and
# boot-style messages.
#

# --- Color Definitions ---
# These variables are used to colorize the output of the logger.
GREEN=$(tput setaf 2)      # Success / Installed
RED=$(tput setaf 1)        # Error
ORANGE=$(tput setaf 3)     # Warning / Failure explanation
BLUE=$(tput setaf 4)       # Information (for headers only)
LIGHT_CYAN=$(tput setaf 14) # Secondary Information
GRAY=$(tput setaf 8)       # Neutral / Comment
MAGENTA=$(tput setaf 5)    # Prompts
BOLD=$(tput bold)          # Bold attribute
NC=$(tput sgr0)            # Reset color and attributes

# --- Indentation ---
INDENT="  " # Two spaces for indentation of log lines

# --- Layout ---
LINE_WIDTH=110
STATUS_WIDTH=110
SUB_STATUS_WIDTH=$((STATUS_WIDTH - 2))

#
# log_header_h1(message)
#
# Prints a level 1 header.
#
log_header_h1() {
    echo -e "\n${BOLD}${BLUE}# $1${NC}"
    printf "${BLUE}%.0s${NC}" $(seq 1 $LINE_WIDTH)
    echo ""
}

#
# log_header_h2(message)
#
# Prints a level 2 header.
#
log_header_h2() {
    echo -e "\n${BOLD}${LIGHT_CYAN}## $1${NC}"
    printf "%.0s" $(seq 1 $LINE_WIDTH)
    echo ""
}

#
# log_separator()
#
# Prints a separator line.
#
log_separator() {
    printf "%.0s" $(seq 1 $LINE_WIDTH)
    echo ""
}

#
# log_info(message)
#
# Prints an informational message.
#
log_info() {
    echo -e "${INDENT}${BOLD}${GRAY}$1${NC}"
}

#
# log_prompt(message)
#
# Prints a prompt message.
#
log_prompt() {
    echo -e "${INDENT}${BOLD}${MAGENTA}$1${NC}"
}

#
# log_boot_start(message)
#
# Prints the start of a boot-style message.
#
log_boot_start() {
    printf "${INDENT}%-${STATUS_WIDTH}s" "$1"
}

#
# log_sub_boot_start(message)
#
# Prints the start of a sub boot-style message.
#
log_sub_boot_start() {
    printf "${INDENT}${GRAY}└${NC} %-${SUB_STATUS_WIDTH}s" "$1"
}

#
# log_boot_success()
#
# Prints a success message for a boot-style log.
#
log_boot_success() {
    echo -e "[ ${BOLD}${GREEN}INSTALLED${NC} ]"
}

#
# log_boot_skipped()
#
# Prints a skipped message for a boot-style log.
#
log_boot_skipped() {
    echo -e "[ ${BOLD}${GREEN} SKIPPED ${NC} ]"
}

#
# log_boot_skipped_comment()
#
# Prints a comment message for a boot-style log.
#
log_boot_skipped_comment() {
    echo -e "[ ${BOLD}${GRAY} COMMENT ${NC} ]"
}

#
# log_boot_failure(message)
#
# Prints a failure message for a boot-style log.
#
log_boot_failure() {
    local error_message="$1"
    echo -e "[ ${BOLD}${RED} FAILED  ${NC} ]"
    echo -e "${INDENT}${INDENT}${RED}Error Detail: ${NC}${ORANGE}${error_message}${NC}"
}

#
# log_boot_ok()
#
# Prints an OK message for a boot-style log.
#
log_boot_ok() {
    echo -e "[ ${BOLD}${GREEN}   OK    ${NC} ]"
}