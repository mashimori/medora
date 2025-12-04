#!/bin/bash

#
# intro.sh
#
# This script displays an introductory banner for the Fedora Setup Script.
#

# --- Terminal Color Configuration ---
DESCRIPTION=$(tput setaf 3)
BOLD=$(tput bold)
CLEAR=$(tput sgr0)
FRAME=$(tput setaf 3)
FIRST_PART=$(tput setaf 13)
SECOND_PART=$(tput setaf 14)


# --- Display Introductory Banner ---
echo ""
echo -e "${FRAME}╔═══════════════════════════════════════════════════════════════════╗${CLEAR}"
echo -e "${FRAME}║${CLEAR}                ${DESCRIPTION}Welcome to Fedora Setup Script! ${CLEAR}                   ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}                                                                   ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}     ${FIRST_PART}_____  ___________${CLEAR}${SECOND_PART}________   ________  _________    _____     ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}    ${FIRST_PART}/     \ \_   _____/${CLEAR}${SECOND_PART}\______ \  \_____  \\ \______  \  /  _  \    ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}   ${FIRST_PART}/  \ /  \ |    __)_${CLEAR}${SECOND_PART}  |    |  \  /   |   \|       _/ /  /_\  \   ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}  ${FIRST_PART}/    Y    \|        \\${CLEAR}${SECOND_PART} |    '   \/    |    \    |   \/    |    \\  ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}  ${FIRST_PART}\____|__  /_______  /${CLEAR}${SECOND_PART}/_______  /\_______  /____|_  /\____|__  /  ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}          ${FIRST_PART}\/        \/${CLEAR}${SECOND_PART}         \/         \/       \/         \/   ${FRAME}║${CLEAR}"
echo -e "${FRAME}║${CLEAR}                                                                   ${FRAME}║${CLEAR}"
echo -e "${FRAME}╚═══════════════════════════════════════════════════════════════════╝${CLEAR}"
echo ""
