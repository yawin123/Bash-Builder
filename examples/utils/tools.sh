#!/usr/bin/env bash

#|--/ /+------------+--/ /|#
#|-/ /-| Misc tools |-/ /-|#
#|/ /--+------------+/ /--|#

safe_export() {
    local var_name=""
    local default_value=""
    local is_array=false

    # Parsear parámetros
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name|-n) var_name="$2"; shift 2 ;;
            --default|-d) default_value="$2"; shift 2 ;;
            --array|-a) is_array=true; shift ;;
            *) echo "Parámetro desconocido: $1" >&2; return 1 ;;
        esac
    done

    [[ -z "$var_name" ]] && { echo "Falta nombre de variable" >&2; return 1; }
    [[ -v $var_name ]] && return

    if $is_array; then
        eval "export $var_name=($default_value)"
    else
        eval "export $var_name=\"$default_value\""
    fi
}
