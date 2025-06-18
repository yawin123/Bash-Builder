#!/bin/bash

source datastore.sh
source tools.sh

data.set "linux" "./linux"
data.set "linux" ".so"

data.set "windows" "./windows"
data.set "windows" ".dll"
data.set "windows" ".dll.a"

safe_export --name cbuild_pwd
safe_export --name cbuild_platform_selected
safe_export --name cbuild_platform_data
safe_export --name cbuild_project_name

cbuild.set_project() {
  cbuild_project_name=$1
}

cbuild.clean_all() {
  data.keys plataformas
  for ((i=0; i<${#plataformas[@]}; i++)); do
    data.get ${plataformas[i]} folders
    if [[ -d ${folders[0]} ]]; then
      rm -Rf ${folders[0]}
    fi
  done
}

cbuild.leave_platform() {
  cbuild_platform_selected=""
  cd $cbuild_pwd
}

cbuild.enter_platform() {
  cbuild_platform_selected=$1
  cbuild_pwd=$(pwd)

  data.get $cbuild_platform_selected cbuild_platform_data

  if [[ ! -d ${cbuild_platform_data[0]} ]]; then
    mkdir "${cbuild_platform_data[0]}" || cbuild.leave_platform
  fi

  cd "${cbuild_platform_data[0]}"
}

cbuild.clean() {
  if [[ -n $cbuild_platform_selected ]]; then
    FOLDER=${cbuild_platform_data[0]}
    cbuild.leave_platform
  elif [[ -n $1 ]] && data.has $1; then
    data.get $1 lista
    FOLDER=${lista[0]}
  fi

  if [[ -n $FOLDER && -d $FOLDER ]]; then
    rm -Rf "$FOLDER"
  fi
}

cbuild.cmake() {
  # Verificar que $cbuild_pwd esté definida y sea un directorio válido
  if [[ -z "$cbuild_pwd" ]]; then
    echo "Error: cbuild_pwd no está definida o no es un directorio válido" >&2
    return 0
  fi

  # Verificar Makefile (nótese que el ls inicial no era necesario)
  if [[ ! -f "Makefile" ]]; then
    # Construir argumentos de manera segura
    local ARGS=("$cbuild_pwd/..")

    # Añadir toolchain si existe
    if [[ -n "$cbuild_platform_selected" && -f "$cbuild_pwd/../$cbuild_platform_selected.cmake" ]]; then
      ARGS+=("-DCMAKE_TOOLCHAIN_FILE=$cbuild_pwd/../$cbuild_platform_selected.cmake")
    fi

    echo "Ejecutando: cmake ${ARGS[*]}"
    cmake "${ARGS[@]}" || {
      echo "Error: Falló la ejecución de cmake" >&2
      return 1
    }
  fi
}

cbuild.save() {
  for ((i=1; i<${#cbuild_platform_data[@]}; i++)); do
    FILE=$cbuild_project_name${cbuild_platform_data[$i]}
    if [[ -f $FILE ]]; then
      mv $FILE $cbuild_pwd
    fi
  done
}

cbuild.build() {
  cbuild.cmake
  cmake --build . --parallel $(nproc --ignore=1)
}
