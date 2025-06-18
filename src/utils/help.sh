#!/usr/bin/env bash
#|--/ /+--------------+--/ /|#
#|-/ /-| Help utility |-/ /-|#
#|/ /--+--------------+/ /--|#

source tools.sh
source log.sh

help.description() {
  safe_export --name HELP_DESCRIPTION --default "$1"
}

# Diccionario de tipos a listas de claves de opciones
declare -A HELP_TYPES
# Diccionario de opciones: clave -> comando
declare -A HELP_COMMANDS
# Diccionario de opciones: clave -> descripción
declare -A HELP_DESCRIPTIONS

# Contador para generar claves únicas
HELP_INDEX=0

help.add_option() {
    local command="$1"
    local description="$2"
    local type="${3:-General}"

    local key="opt_$HELP_INDEX"
    ((HELP_INDEX++))

    # Guardamos la opción
    HELP_COMMANDS[$key]="$command"
    HELP_DESCRIPTIONS[$key]="$description"

    # Asociamos la opción al tipo
    HELP_TYPES[$type]+="$key "
}

# Función para mostrar la ayuda
help.show() {
  printf "$HELP_DESCRIPTION\n\n"
  printf "${GREEN}Usage:$RESET $CYAN$(basename $0) [OPTIONS]$RESET\n\n"

  # Mostrar primero el tipo "General"
  if [[ -n "${HELP_TYPES[General]}" ]]; then
    printf "${GREEN}General options:$RESET\n"
    for key in ${HELP_TYPES[General]}; do
      printf " $CYAN${HELP_COMMANDS[$key]}$RESET  ${HELP_DESCRIPTIONS[$key]}\n"
    done
    echo
  fi

  # Mostrar el resto de tipos
  for type in "${!HELP_TYPES[@]}"; do
    if [[ "$type" != "General" ]]; then
      printf "${GREEN}$type options:$RESET\n"
      for key in ${HELP_TYPES[$type]}; do
        printf " $CYAN${HELP_COMMANDS[$key]}$RESET  ${HELP_DESCRIPTIONS[$key]}\n"
      done
      echo
    fi
  done
}
