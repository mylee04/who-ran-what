#!/bin/bash

# Color definitions for who-ran-what
# shellcheck disable=SC2034  # Colors are defined for use by sourcing scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Symbols
CHECK_MARK="[OK]"
CROSS_MARK="[X]"
WARNING="[!]"
INFO="[i]"
ARROW="[>]"

# Output functions
info() {
    echo -e "${CYAN}${INFO}${RESET} $1"
}

success() {
    echo -e "${GREEN}${CHECK_MARK}${RESET} $1"
}

error() {
    echo -e "${RED}${CROSS_MARK}${RESET} $1" >&2
}

warning() {
    echo -e "${YELLOW}${WARNING}${RESET} $1"
}

header() {
    echo -e "\n${BOLD}$1${RESET}"
}

dim() {
    echo -e "${DIM}$1${RESET}"
}
