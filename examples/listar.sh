#!/bin/bash
set -Euo pipefail

source utils/help.sh
source utils/summary.sh

help.description "Listar archivos y directorios de una ruta.\nUso: listar [OPCIONES] <ruta>"
help.add_option "-h       " "Mostrar esta ayuda"
help.add_option "-f       " "Listar solo ficheros"
help.add_option "-d       " "Listar solo directorios"
help.add_option "<ruta>   " "Ruta a listar"

MOSTRAR_FICHEROS=false
MOSTRAR_DIRS=false
FLAG_F_SET=false
FLAG_D_SET=false
RUTA=""

while getopts :hfd opt; do
  case $opt in
    h) help.show; exit 0 ;;
    f) FLAG_F_SET=true ;;
    d) FLAG_D_SET=true ;;
    ?) error.log "Opción no válida: -$OPTARG"; help.show; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Sin flags: ambos. Con ambos flags: ambos. Con uno solo: solo ese.
if ! $FLAG_F_SET && ! $FLAG_D_SET; then
  MOSTRAR_FICHEROS=true
  MOSTRAR_DIRS=true
else
  MOSTRAR_FICHEROS=$FLAG_F_SET
  MOSTRAR_DIRS=$FLAG_D_SET
fi

RUTA="${1:-}"

if [[ -z "$RUTA" ]]; then
  help.show
  exit 0
fi

if [[ ! -d "$RUTA" ]]; then
  error.log "La ruta '$RUTA' no existe o no es un directorio"
  exit 1
fi

summary.setup "Nombre:30:." "Tipo:5: "

for item in "$RUTA"/*; do
  [[ -e "$item" ]] || continue
  nombre=$(basename "$item")
  if [[ -d "$item" ]] && $MOSTRAR_DIRS; then
    summary.add "$nombre" "DIR "
  elif [[ -f "$item" ]] && $MOSTRAR_FICHEROS; then
    summary.add "$nombre" "FILE"
  fi
done

summary.show
