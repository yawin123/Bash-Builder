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

safe_declare() {
    local var_name=""
    local default_value=""
    local type_flag=""

    # Parsear parámetros
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name|-n) var_name="$2"; shift 2 ;;
            --default|-d) default_value="$2"; shift 2 ;;
            --array|-a) type_flag="-a"; shift ;;
            --assoc|-A) type_flag="-A"; shift ;;
            *) echo "Parámetro desconocido: $1" >&2; return 1 ;;
        esac
    done

    # Validar que al menos venga el nombre
    [[ -z "$var_name" ]] && { echo "Falta nombre de variable" >&2; return 1; }
    
    # Si la variable ya existe, no tocamos nada (Safe)
    [[ -v $var_name ]] && return

    # Declarar dinámicamente según el tipo
    if [[ "$type_flag" == "-a" || "$type_flag" == "-A" ]]; then
        if [[ -z "$default_value" ]]; then
            eval "declare -g $type_flag $var_name=()"
        else
            eval "declare -g $type_flag $var_name=($default_value)"
        fi
    else
        eval "declare -g $var_name=\"$default_value\""
    fi
}