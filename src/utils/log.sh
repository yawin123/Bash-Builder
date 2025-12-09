#!/usr/bin/env bash

#|--/ /+-----------+--/ /|#
#|-/ /-| Log utils |-/ /-|#
#|/ /--+-----------+/ /--|#

#---------#
# Colours #
#---------#
RED="\033[0;31m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

color.red() {
  echo -e "$RED$1$RESET"
}
color.blue() {
  echo -e "$BLUE$1$RESET"
}
color.cyan() {
  echo -e "$CYAN$1$RESET"
}
color.green() {
  echo -e "$GREEN$1$RESET"
}
color.yellow() {
  echo -e "$YELLOW$1$RESET"
}

#---------#
# Logging #
#---------#
function message { printf "%s $1\n" '--'; }
function error.log { message "$RED$1$RESET"; }
function info.log { message "$GREEN$1$RESET"; }
function debug.log { message "$BLUE$1$RESET"; }

error() {
  error.log "Error: $1"
  exit 1
}
