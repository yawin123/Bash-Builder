#!/usr/bin/env bash

#|--/ /+-----------------+--/ /|#
#|-/ /-| Minify utility  |-/ /-|#
#|/ /--+-----------------+/ /--|#

# ----------------------------------------------------------------------
# minify.file <entrada> [salida]
#
# Minifica un fichero bash aplicando transformaciones seguras:
#   - Conserva la línea shebang (#!/...) si existe
#   - Elimina comentarios de línea completa (líneas cuyo primer
#     carácter no blanco es #)
#   - Elimina líneas vacías o compuestas solo de espacios
#   - Elimina espacios al inicio y al final de cada línea
#   - Elimina espacios alrededor de |, ||, &&, ;
#   - Compacta redirecciones (> file → >file)
#   - Elimina la keyword "function"
#   - Colapsa espacios múltiples consecutivos
#
# Si no se especifica salida, el resultado va a stdout.
# ----------------------------------------------------------------------
minify.file() {
  local input="$1"
  local output="${2:-}"

  if [[ ! -f "$input" ]]; then
    echo "[minify] Error: fichero no encontrado: $input" >&2
    return 1
  fi

  if [[ -n "$output" ]]; then
    # Si entrada y salida son el mismo fichero, usar un temporal
    # para no truncar el fichero antes de leerlo
    if [[ "$(realpath "$input")" == "$(realpath "$output")" ]]; then
      local tmp
      tmp="$(mktemp)"
      _minify_stream < "$input" > "$tmp"
      mv "$tmp" "$output"
    else
      _minify_stream < "$input" > "$output"
    fi
  else
    _minify_stream < "$input"
  fi
}

# ----------------------------------------------------------------------
# _minify_stream
#
# Función interna que procesa línea a línea desde stdin.
# Busca el shebang en las primeras 10 líneas y lo coloca al inicio
# de la salida. Luego procesa el resto eliminando comentarios de línea
# completa, líneas vacías y espacios sobrantes.
# ----------------------------------------------------------------------
_minify_stream() {
  local shebang=""
  local lines=()
  local line trimmed

  # Primera pasada: leer todas las líneas a un array y detectar shebang
  while IFS= read -r line || [[ -n "$line" ]]; do
    lines+=("$line")
    # Detectar shebang en cualquier posición (solo el primero)
    if [[ -z "$shebang" && "$line" =~ ^[[:space:]]*#!/ ]]; then
      trimmed="${line#"${line%%[![:space:]]*}"}"
      shebang="$trimmed"
    fi
  done

  # Si no se encontró shebang, usar uno por defecto
  [[ -z "$shebang" ]] && shebang="#!/bin/bash"

  # Emitir shebang como primera línea
  printf '%s\n' "$shebang"

  # Segunda pasada: emitir líneas no vacías ni comentarios, saltando el shebang
  for line in "${lines[@]}"; do
    # Eliminar espacios al inicio y final
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    # Saltar cualquier shebang (ya se emitió el primero al inicio)
    [[ "$trimmed" =~ ^#!/ ]] && continue

    # Saltar líneas vacías
    [[ -z "$trimmed" ]] && continue

    # Saltar comentarios de línea completa
    [[ "$trimmed" == "#"* ]] && continue

    # Aplicar transformaciones agresivas
    _squeeze_line "$trimmed"
  done
}

# ----------------------------------------------------------------------
# _squeeze_line <línea>
#
# Aplica transformaciones agresivas a una línea individual mediante sed:
#   - Elimina la keyword "function" en definiciones
#   - Elimina espacios alrededor de |, ||, &&
#   - Elimina espacio antes de ; y ;;
#   - Compacta redirecciones (> file → >file)
#   - Colapsa espacios múltiples consecutivos
# ----------------------------------------------------------------------
_squeeze_line() {
  printf '%s\n' "$1" | sed -E \
    -e 's/^function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_.]*)[[:space:]]*\{/\1()\{/' \
    -e 's/^function[[:space:]]+//' \
    -e 's/ \|\| /||/g' \
    -e 's/ \| /|/g' \
    -e 's/ && /\&\&/g' \
    -e 's/ &&\b/\&\&/g' \
    -e 's/\b&& /\&\&/g' \
    -e 's/ ;/;/g' \
    -e 's/;; /;;/g' \
    -e 's/ ;;/;;/g' \
    -e 's/([0-9]?>>?)[[:space:]]+/\1/g' \
    -e 's/(<<<)[[:space:]]+/\1/g' \
    -e 's/[[:space:]]{2,}/ /g'
}
