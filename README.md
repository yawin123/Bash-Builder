# Bash Builder

**Bash Builder** es una herramienta que convierte un script Bash con múltiples dependencias en un único fichero autocontenido. Ideal para distribuir scripts complejos sin preocuparse por rutas relativas, orden de carga o dependencias circulares.

El propio `builder` está construido con este sistema: el punto de entrada está en [`examples/builder`](examples/builder) y la biblioteca de utilidades en [`examples/utils/`](examples/utils/).

---

## Quick Start

Clonar el repositorio y generar un primer bundle:

```bash
git clone https://git.yawin.es/personal/bash-builder.git
cd bash-builder

# Empaquetar el script de ejemplo con sus dependencias
./builder -e examples/listar.sh -o ./listar

# Ejecutar el bundle resultante
bash ./listar -h
bash ./listar ./
```

El script generado `listar` es completamente autocontenido: incluye `help.sh` y `summary.sh` (y sus dependencias) resueltos y sin duplicados. No necesita los fuentes originales para ejecutarse.

Para una salida más compacta, añadir `-m`:

```bash
./builder -e examples/listar.sh -o ./listar -m
```

La reducción es de ~31% (320 → 220 líneas) manteniendo la misma semántica.

---

## Cómo funciona

1. Toma un script de entrada (el *entrypoint*) y lo recorre línea por línea.
2. Cuando encuentra una instrucción `source <fichero>` o `. <fichero>`, resuelve la ruta real del fichero referenciado y lo procesa recursivamente.
3. Cada fichero se inyecta en la salida una sola vez: las inclusiones duplicadas se marcan como `[SKIPPED]`.
4. El shebang del entrypoint se coloca al principio absoluto de la salida; los shebangs del resto de ficheros se descartan automáticamente.
5. Las líneas que no son `source` se copian tal cual.
6. El resultado se escribe en el fichero de salida, listo para ejecutar.

---

## Uso

```
builder [OPCIONES]
```

| Opción | Descripción |
|--------|-------------|
| `-h` | Muestra la ayuda |
| `-e <ruta>` | Script de entrada (el que contiene los `source`) |
| `-o <ruta>` | Fichero de salida (el bundle generado) |
| `-m` | Minifica la salida |

### Ejemplos incluidos

El proyecto incluye dos scripts de ejemplo empaquetables:

| Script | Utilidades usadas | Complejidad |
|---|---|---|
| `examples/listar.sh` | `help.sh`, `summary.sh` | Básico, lista ficheros y directorios con filtros `-f`/`-d` |
| `examples/builder` | `help.sh`, `minify.sh` | Avanzado, es el propio builder |

```bash
./builder -e examples/listar.sh -o ./listar
./listar -f examples/
```

---

## Minificación

Al usar `-m`, el builder aplica una serie de transformaciones sobre la salida:

| Transformación | Antes | Después |
|---|---|---|
| Sin comentarios de línea completa | `# esto es un comentario` | (eliminado) |
| Sin líneas vacías | Líneas en blanco | (eliminadas) |
| Sin keyword `function` | `function foo() {` | `foo(){` |
| Sin espacios en `\|\|`, `&&`, `\|` | `cmd \|\| other` | `cmd\|\|other` |
| Sin espacio antes de `;` | `cmd ; other` | `cmd; other` |
| Redirecciones compactas | `> /dev/null` | `>/dev/null` |
| Espacios múltiples colapsados | `local   var` | `local var` |

La salida minificada es sintácticamente equivalente al original. Reducciones observadas:

| Ejemplo | Normal | Minificado | Reducción |
|---|---|---|---|
| `listar.sh` | 320 líneas | 220 líneas | ~31% |
| `builder` | 397 líneas | 240 líneas | ~39% |

---

## Estructura del proyecto

```
bash-builder/
├── builder                 # El bundle autocontenido (ejecutable)
├── examples/
│   ├── builder             # Fuente del builder (entrypoint)
│   ├── listar.sh           # Ejemplo básico (help + summary)
│   └── utils/              # Biblioteca de utilidades compartidas
│       ├── tools.sh        # safe_export, colores
│       ├── help.sh         # Sistema de ayuda (-h)
│       ├── log.sh          # Funciones de log
│       ├── datastore.sh    # Almacén clave-valor en memoria
│       ├── minify.sh       # Minificador interno
│       ├── summary.sh      # Tablas resumen formateadas
│       └── timer.sh        # Temporizador
└── LICENSE                 # GPLv3
```

---

## Cómo reconstruir el builder

Si se modifican los fuentes en `examples/`, regenerar el bundle:

```bash
./builder -e examples/builder -o ./builder
```

El builder puede reconstruirse a sí mismo. Para probar sin sobrescribir, crear y usar el directorio `build/`:

```bash
mkdir -p build
./builder -e examples/builder -o build/builder
```

---

## Licencia

GNU General Public License v3.0. Consulta el fichero [LICENSE](LICENSE) para más detalles.

---

## Autor

Miguel Albors Iruretagoyena (Yawin)

