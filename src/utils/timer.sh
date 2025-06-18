#!/usr/bin/env bash

#|--/ /+-------------+--/ /|#
#|-/ /-| Timer utils |-/ /-|#
#|/ /--+-------------+/ /--|#

source tools.sh

safe_export --name TIMER_CHRONO

timer.start() {
  TIMER_CHRONO=$EPOCHREALTIME
}

timer.stop() {
  TIMER_CHRONO=$(bc <<<"($EPOCHREALTIME - $TIMER_CHRONO) / 0.01 * 0.01")
  echo $TIMER_CHRONO
}
