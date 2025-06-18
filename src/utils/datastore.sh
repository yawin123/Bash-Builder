#!/bin/bash

declare -A datos

data.set() {
    local clave=$1
    local valor=$2

    # Si ya hay datos, agregamos con separador
    if [ -n "${datos[$clave]}" ]; then
        datos["$clave"]+="|$valor"
    else
        datos["$clave"]="$valor"
    fi
}

data.get() {
    local clave=$1
    local variable=$2

    if [ -n "${datos[$clave]}" ]; then
        # Guardar en la variable especificada
        IFS='|' read -ra "$variable" <<< "${datos[$clave]}"
    fi
}

data.has() {
    local clave=$1
    if [[ -n "${datos[$clave]+x}" ]]; then
        return 0  # Existe (true)
    else
        return 1  # No existe (false)
    fi
}

# Función que devuelve todas las claves existentes
data.keys() {
    local -n output_array=$1  # Usamos nameref para devolver el array por referencia

    # Obtener todas las claves del array asociativo
    output_array=("${!datos[@]}")
}
