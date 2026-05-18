#!/usr/bin/env bash

# Carga tools.sh de forma relativa al script actual
source tools.sh

#|--/ /+---------------+--/ /|#
#|-/ /-| Summary utils |-/ /-|#
#|/ /--+---------------+/ /--|#

# Configuración dinámica
safe_export --name SUMMARY_HEADERS        --array
safe_export --name SUMMARY_ROWS           --array
safe_export --name SUMMARY_COL_WIDTHS     --array
safe_export --name SUMMARY_COL_FILL_CHAR  --array
safe_export --name SUMMARY_NUM_COLS       --default 0
safe_export --name SUMMARY_SHOW_HEADER    --default 1

# Función para configurar la tabla
function summary.setup {
    SUMMARY_HEADERS=()
    SUMMARY_ROWS=()
    SUMMARY_COL_WIDTHS=()
    SUMMARY_COL_FILL_CHAR=()
    SUMMARY_SHOW_HEADER=1  # Mostrar encabezado por defecto

    if [[ "$1" == "--no-header" ]]; then
        SUMMARY_SHOW_HEADER=0
        shift
    fi

    SUMMARY_NUM_COLS=$#

    for arg in "$@"; do
        IFS=':' read -r titulo ancho relleno <<< "$arg"
        SUMMARY_HEADERS+=("$titulo")

        if [[ -n "$ancho" && "$ancho" =~ ^[0-9]+$ ]]; then
            SUMMARY_COL_WIDTHS+=("$ancho")
        else
            SUMMARY_COL_WIDTHS+=("${#titulo}")
        fi

        SUMMARY_COL_FILL_CHAR+=("$relleno")
    done
}

# Función para añadir datos
function summary.add {
    if [ $# -ne $SUMMARY_NUM_COLS ]; then
        echo "Error: la fila debe tener $SUMMARY_NUM_COLS columnas, pero se dieron $#."
        return 1
    fi

    SUMMARY_ROWS+=("$(IFS=$'\t'; echo "$*")")
}

# Función para mostrar el resumen completo
function summary.show {
    # Función auxiliar para imprimir una fila con padding
    summary.__show_row() {
        local -n fila=$1
        local override_fill_char="${2:-}"

        printf " "
        for ((i=0; i<SUMMARY_NUM_COLS; i++)); do
            local contenido="${fila[$i]}"
            local ancho="${SUMMARY_COL_WIDTHS[$i]}"
            local longitud=${#contenido}
            local espacio=$((ancho - longitud))
            local relleno="${override_fill_char:-${SUMMARY_COL_FILL_CHAR[$i]}}"

            if [[ -n "$relleno" && $espacio -gt 0 ]]; then
                printf "%s" "$contenido"
                for ((j=0; j<espacio; j++)); do
                    printf "%s" "$relleno"
                done
            else
                printf "%-*s" "$ancho" "$contenido"
            fi

            if [ $i -lt $((SUMMARY_NUM_COLS - 1)) ]; then
                printf " "
            fi
        done
        printf "\n"
    }

    # Función auxiliar para pintar separadores
    summary.__show_separator() {
        for ((i=0; i<SUMMARY_NUM_COLS; i++)); do
            sep=""
            for ((j=0; j<${SUMMARY_COL_WIDTHS[$i]}; j++)); do
                sep+="─"
            done
            printf "%s" "$sep"
            if [ $i -lt $((SUMMARY_NUM_COLS - 1)) ]; then
                printf "%s" "──"
            fi
        done
        printf "\n"
    }

    # Mostrar encabezado si está habilitado
    if [[ "$SUMMARY_SHOW_HEADER" -eq 1 ]]; then
        summary.__show_separator
        summary.__show_row SUMMARY_HEADERS " "
        summary.__show_separator
    fi

    # Imprimir filas
    for row in "${SUMMARY_ROWS[@]}"; do
        IFS=$'\t' read -r -a values <<< "$row"
        summary.__show_row values
    done
}
