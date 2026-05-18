#!/usr/bin/env bash

source tools.sh
source log.sh

#|--/ /+--------------+--/ /|#
#|-/ /-| Help utility |-/ /-|#
#|/ /--+--------------+/ /--|#

help.description() {
  safe_declare --name HELP_DESCRIPTION --default "$1"
}

# Diccionario de tipos a listas de claves de opciones
safe_declare --name HELP_TYPES --assoc
# Diccionario de opciones: clave -> comando
safe_declare --name HELP_COMMANDS --assoc
# Diccionario de opciones: clave -> descripción
safe_declare --name HELP_DESCRIPTIONS --assoc

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
help.show_description() {
  printf "$HELP_DESCRIPTION\n\n"
}
help.show() {
  help.show_description
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
