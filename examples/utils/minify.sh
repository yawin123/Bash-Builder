#!/usr/bin/env bash

#|--/ /+-----------------+--/ /|#
#|-/ /-| Minify utility  |-/ /-|#
#|/ /--+-----------------+/ /--|#

# ----------------------------------------------------------------------
# minify.file <entrada> [salida]
#
# Minifica un fichero bash aplicando transformaciones seguras.
# ----------------------------------------------------------------------
minify.file() {
  local input="$1"
  local output="${2:-}"

  if [[ ! -f "$input" ]]; then
    echo "[minify] Error: fichero no encontrado: $input" >&2
    return 1
  fi

  if [[ -n "$output" ]]; then
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
# ----------------------------------------------------------------------
_minify_stream() {
  local shebang=""
  local lines=()
  local line trimmed
  local in_heredoc=false
  local heredoc_delimiter=""

  # Primera pasada: leer todas las líneas a un array y detectar shebang
  while IFS= read -r line || [[ -n "$line" ]]; do
    lines+=("$line")
    if [[ -z "$shebang" && "$line" =~ ^[[:space:]]*#!/ ]]; then
      trimmed="${line#"${line%%[![:space:]]*}"}"
      shebang="$trimmed"
    fi
  done

  [[ -z "$shebang" ]] && shebang="#!/bin/bash"
  printf '%s\n' "$shebang"

  # Segunda pasada: emitir líneas procesadas
  for line in "${lines[@]}"; do
    # Protección total para Here Documents
    if $in_heredoc; then
      printf '%s\n' "$line"
      trimmed_close="${line#"${line%%[![:space:]]*}"}"
      trimmed_close="${trimmed_close%"${trimmed_close##*[![:space:]]}"}"
      if [[ "$trimmed_close" == "$heredoc_delimiter" ]]; then
        in_heredoc=false
      fi
      continue
    fi

    # Limpieza de espacios iniciales y finales fuera de bloques
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    [[ "$trimmed" =~ ^#!/ ]] && continue
    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" == "#"* ]] && continue

    # Detectar el inicio de un Here Document (captura el delimitador limpio)
    if [[ "$trimmed" =~ \<\<-?[[:space:]]*['"']?([a-zA-Z0-9_]+)['"']? ]]; then
      in_heredoc=true
      heredoc_delimiter="${BASH_REMATCH[1]}"
    fi

    _squeeze_line "$trimmed"
  done
}

# ----------------------------------------------------------------------
# _squeeze_line <línea>
# ----------------------------------------------------------------------
_squeeze_line() {
  printf '%s\n' "$1" | sed -E \
    -e 's/^function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_.]*)[[:space:]]*\{/\1()\{/' \
    -e 's/^function[[:space:]]+//' \
    -e 's/[[:space:]]*\|\|[[:space:]]*/||/g' \
    -e 's/[[:space:]]*\|[[:space:]]*/|/g' \
    -e 's/[[:space:]]*&&[[:space:]]*/\&\&/g' \
    -e 's/[[:space:]]*;[[:space:]]*/;/g' \
    -e 's/[[:space:]]*;;[[:space:]]*/;;/g' \
    -e 's/(<<<)[[:space:]]+/\1/g' \
    -e 's/([^"''\\])[[:space:]]{2,}/\1 /g'
}