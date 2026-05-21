#!/bin/bash

# ==============================================================================
# BATERÍA DE PRUEBAS COMPLETA, ABSOLUTA Y EXTREMA PARA MINIMIZADORES DE BASH
# ==============================================================================
# Este script toca todos los componentes clave de la sintaxis de Bash.
# Al ejecutarse, NO debe dar errores y debe imprimir "--- FIN DEL TEST EXTREMO ---".

set -e # Salir si algo falla para asegurar la integridad de la prueba

# ==============================================================================
# 1. CONTROL DE SEÑALES, TRAMPAS Y ENTORNO (TRAPS & ALIASES)
# ==============================================================================
echo "--- 1. Trampas y Alias ---"
shopt -s expand_aliases
alias testalias='echo "  -> Alias expandido con éxito"'

# Provocar un trigger controlado de EXIT al final para verificar el trap
trap 'echo; echo "--- FIN DEL TEST EXTREMO ---"' EXIT

testalias

# ==============================================================================
# 2. PROCESAMIENTO PARALELO, SUBSHELLS Y MANEJO DE PIDs
# ==============================================================================
echo "--- 2. Procesos en Fondo y Subshells ---"
(
    echo "  -> Dentro de subshell anidada (Nivel 1)"
    ( echo "    -> Dentro de subshell anidada (Nivel 2)" )
)

# Ejecución en fondo con operador '&' y captura de PID especial ($!)
sleep 0.1 &
PID_FONDO=$!
echo "  -> Proceso de fondo lanzado con PID: $PID_FONDO"
wait $PID_FONDO
echo "  -> Proceso de fondo terminado con código: $?"

# ==============================================================================
# 3. EXPANSIÓN DE PARÁMETROS ESOTÉRICA (EL INFIERNO DEL PARSER)
# ==============================================================================
echo "--- 3. Expansión de Parámetros Avanzada ---"
TEXTO_TEST="AbCdEfGhIjK_MINIMIZAME_ESTA"

echo "  -> Longitud (\${#}): ${#TEXTO_TEST}"
echo "  -> Subcadena (\${var:offset:len}): ${TEXTO_TEST:2:5}"
echo "  -> Conversión a minúsculas (\${var,,}): ${TEXTO_TEST,,}"
echo "  -> Conversión a mayúsculas (\${var^^}): ${TEXTO_TEST^^}"
echo "  -> Eliminación por patrón por detrás (\${var%_*}): ${TEXTO_TEST%_*}"
echo "  -> Eliminación por patrón por delante (\${var#*_}): ${TEXTO_TEST#*_}"
echo "  -> Sustitución global (\${var//patron/reemplazo}): ${TEXTO_TEST//_/-}"

# Indirecta de variables (Variable nameref / Indirección \${!var})
PUNTERO="TEXTO_TEST"
echo "  -> Indirección de variable (\${!ptr}): ${!PUNTERO}"

# Variables por defecto y verificación de estado
echo "  -> Valor por defecto si está vacía: ${VARIABLE_INEXISTENTE:-'Por defecto'}"

# ==============================================================================
# 4. ARRAYS INDEXADOS Y ASOCIATIVOS (MATRICES)
# ==============================================================================
echo "--- 4. Arrays Indexados y Asociativos ---"
# Array normal
ARRAY_IND=( "uno" "dos con espacios" "tres" )
ARRAY_IND+=( "cuatro" )
echo "  -> Elemento indexado: ${ARRAY_IND[1]}"
echo "  -> Todos los elementos indexados: ${ARRAY_IND[@]}"

# Array asociativo (Clave-Valor) - Requiere declarar explícitamente con 'declare -A'
declare -A ARRAY_ASOC
ARRAY_ASOC=( ["clave1"]="valor_uno" ["clave con espacios"]="valor_dos" )
echo "  -> Elemento asociativo: ${ARRAY_ASOC["clave con espacios"]}"
echo "  -> Listado de claves: ${!ARRAY_ASOC[@]}"

# ==============================================================================
# 5. ARITMÉTICA COMPLEJA, BITWISE Y EVALUACIÓN DE EXPRESIONES
# ==============================================================================
echo "--- 5. Aritmética y Operadores Bitwise ---"
# El espacio en doble paréntesis es híper-crítico en los minimizadores
VALOR_A=10
VALOR_B=2

# Operaciones básicas, pre-incremento, post-incremento y bitwise AND / OR
(( RESULTADO = (VALOR_A << 1) | (VALOR_B >> 1) ))
(( VALOR_A++ ))
(( ++VALOR_B ))

echo "  -> Resultado Bitwise y desplazamientos: $RESULTADO"
echo "  -> Post-incremento: $VALOR_A, Pre-incremento: $VALOR_B"

# Evaluación con let
let "COMPLEX_LET = (5 * 4) / 2"
echo "  -> Let evaluación: $COMPLEX_LET"

# ==============================================================================
# 6. SUSTITUCIÓN DE PROCESOS (PROCESS SUBSTITUTION) Y DESCRIPTORES
# ==============================================================================
echo "--- 6. Sustitución de Procesos y Descriptores ---"
# Generación de descriptores de archivos virtuales efímeros <(cmd) y >(cmd)
# Si tu minimizador mete un espacio entre '<' y '(', rompe la sintaxis de Bash por completo.
diff -u <(echo -e "línea1\nlínea2") <(echo -e "línea1\nlínea2")

# Duplicación y redirección de descriptores de archivos (File Descriptors 3+)
exec 3>&1 # Duplicar STDOUT en el descriptor 3
exec 4> >(cat > /tmp/test_bash_completo.txt) # Redirigir descriptor 4 a una sustitución de proceso

echo "  -> Esto va al descriptor 3 (STDOUT remapeado)" >&3
echo "Texto de prueba para el descriptor 4" >&4

# Cerrar descriptores creados
exec 4>&-
exec 3>&-

sleep 0.1 # Sincronizar buffer de escritura
if [ -f /tmp/test_bash_completo.txt ]; then
    echo "  -> Manipulación de Descriptores y >(cmd): OK"
    rm /tmp/test_bash_completo.txt
fi

# ==============================================================================
# 7. ESTRUCTURAS DE CONTROL DE FLUJO Y EVALUACIONES (EL CORAZÓN DE BASH)
# ==============================================================================
echo "--- 7. Estructuras de Control y Evaluaciones Exóticas ---"

# Condicionales clásicos vs modernos, operadores lógicos avanzados y regex inline
CADENA_REGEX="bash-5.2-release"
if [[ "$CADENA_REGEX" =~ ^bash-[0-9]\.[0-9] ]]; then
    echo "  -> Validación Regex interna de Bash: OK"
fi

# El comando compuesto 'case' con patrones múltiples y caídas (cláusulas ;& y ;;&)
OPCION="b"
case "$OPCION" in
    a) echo "    -> Opción A";;
    b) 
       echo "    -> Opción B encontrada (provocando caída controlada)"
       ;& # Continúa ejecutando el bloque siguiente ignorando el patrón (específico de Bash)
    c) 
       echo "    -> Caída en Opción C ejecutada correctamente"
       ;;
    *) echo "    -> Default";;
esac

# Bucles While, Until y For estilo C clásico
CONTADOR=0
until [ $CONTADOR -ge 1 ]; do
    echo "  -> Bucle 'until' ejecutado una vez"
    ((CONTADOR++))
done

# Bucle For matemático estilo lenguaje C
for ((i=0; i<2; i++)); do
    echo "  -> Bucle For estilo C iteración: $i"
done

# ==============================================================================
# 8. HERE DOCUMENTS, HERE STRINGS Y TRAMPAS DE ESCAPE DE TEXTO
# ==============================================================================
echo "--- 8. Here Docs, Here Strings y Caracteres Especiales ---"

# Here String pasando variables complejas directamente al STDIN
grep "MINIMIZAME" <<< "$TEXTO_TEST" > /dev/null && echo "  -> Here String (<<<): OK"

# Comando multilínea escapado con barras invertidas que mantiene argumentos intactos
echo "  -> Argumento 1" \
     "Argumento 2" \
     "Argumento 3"

# El 'Here Document' DEFINITIVO con tabulaciones ignoradas (<<-) y comillas de control ('EOF')
# Tu parser NO debe borrar el formato, ni las comillas interiores, ni los falsos comentarios de dentro.
cat <<- 'EOF'
	{
		"config": {
			"comentario_falso": "# Esto no es un comentario de Bash, es JSON string",
			"usuario": "$USER_NO_DEBE_EXPANDIRSE",
			"escape": "Línea con \"comillas\" y barras \\"
		}
	}
EOF

# Un bucle en una sola línea que contiene expansiones de comandos nativas (Backticks y $())
for x in `echo "subshell1"` $(echo "subshell2"); do echo "  -> Tokenizado en línea: $x"; done

# ==============================================================================
# 9. GLOBBING (EXPANSIÓN DE COMODINES Y TEXTO)
# ==============================================================================
echo "--- 9. Expansión de Llaves y Globbing ---"
# Expansión de llaves combinatoria (Brace Expansion)
echo "  -> Combinatoria generada: "{A,B}"-"${ARRAY_IND[0]}

# Impedir expansión de caracteres de globbing (Deben salir como literales, no buscar archivos)
echo "  -> Literales protegidos: * ? [a-z] [!0-9] ^ $ \ ` '"

# Desactivar set -e temporalmente para asegurar el disparo limpio del trap final
set +e