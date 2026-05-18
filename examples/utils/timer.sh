#!/usr/bin/env bash

# Carga tools.sh de forma relativa al script actual
source tools.sh

#|--/ /+-------------+--/ /|#
#|-/ /-| Timer utils |-/ /-|#
#|/ /--+-------------+/ /--|#

safe_declare --name TIMER_CHRONO

timer.start() {
  TIMER_CHRONO=$EPOCHREALTIME
}

timer.stop() {
  TIMER_CHRONO=$(bc <<<"($EPOCHREALTIME - $TIMER_CHRONO) / 0.01 * 0.01")
  echo $TIMER_CHRONO
}
