# Bash Builder

**Bash Builder** is a tool that bundles a Bash script and all its dependencies into a single self-contained file. Useful for distributing complex scripts without worrying about relative paths, load order, or circular dependencies.

The `builder` itself is built with this system: the entrypoint lives in [`examples/builder`](examples/builder) and the utility library in [`examples/utils/`](examples/utils/).

---

## Quick Start

Clone the repository and generate your first bundle:

```bash
git clone https://git.yawin.es/personal/bash-builder.git
cd bash-builder

# Bundle the example script with its dependencies
./builder -e examples/listar.sh -o ./listar

# Run the resulting bundle
bash ./listar -h
bash ./listar ./
```

The generated `listar` script is fully self-contained: it includes `help.sh` and `summary.sh` (and their dependencies), deduplicated. It does not need the original sources to run.

For a more compact output, add `-m`:

```bash
./builder -e examples/listar.sh -o ./listar -m
```

That yields ~30% reduction (354 → 245 lines) with identical semantics.

---

## How it works

1. Takes an entrypoint script and processes it line by line.
2. When it finds a `source <file>` or `. <file>` instruction, it resolves the actual path of the referenced file and processes it recursively.
3. Each file is injected into the output exactly once: duplicate inclusions are logged as `[SKIPPED]`.
4. The shebang from the entrypoint is placed at the very top of the output; shebangs from all other files are discarded.
5. Non-`source` lines are copied as-is.
6. The result is written to the output file, ready to execute.

---

## Usage

```
builder [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `-h` | Show help |
| `-e <path>` | Entrypoint script (the one containing the `source` calls) |
| `-o <path>` | Output file (the generated bundle) |
| `-m` | Minify the output |

### Included examples

The project ships two bundleable example scripts:

| Script | Utilities used | Complexity |
|---|---|---|
| `examples/listar.sh` | `help.sh`, `summary.sh` | Basic — lists files and directories with `-f`/`-d` filters |
| `examples/builder` | `help.sh`, `minify.sh` | Advanced — the builder itself |

```bash
./builder -e examples/listar.sh -o ./listar
./listar -f examples/
```

---

## Minification

When `-m` is used, the builder applies a set of transformations to the output:

| Transformation | Before | After |
|---|---|---|
| Strip full-line comments | `# this is a comment` | (removed) |
| Strip blank lines | blank lines | (removed) |
| Remove `function` keyword | `function foo() {` | `foo(){` |
| Collapse spaces around `\|\|`, `&&`, `\|` | `cmd \|\| other` | `cmd\|\|other` |
| Remove space before `;` | `cmd ; other` | `cmd; other` |
| Compact redirections | `> /dev/null` | `>/dev/null` |
| Collapse multiple spaces | `local   var` | `local var` |

Minified output is syntactically equivalent to the original. Observed reductions:

| Example | Normal | Minified | Reduction |
|---|---|---|---|
| `listar.sh` | 354 lines | 245 lines | ~30% |
| `builder` | 414 lines | 277 lines | ~33% |
| `gentoo-smart-updater` | 653 lines | 471 lines | ~27% |

---

## Project structure

```
bash-builder/
├── builder                 # Self-contained bundle (executable)
├── examples/
│   ├── builder             # Builder source (entrypoint)
│   ├── listar.sh           # Basic example (help + summary)
│   └── utils/              # Shared utility library
│       ├── tools.sh        # safe_export, colors
│       ├── help.sh         # Help system (-h)
│       ├── log.sh          # Logging functions
│       ├── datastore.sh    # In-memory key-value store
│       ├── minify.sh       # Internal minifier
│       ├── summary.sh      # Formatted summary tables
│       └── timer.sh        # Timer
└── LICENSE
```

---

## Rebuilding the builder

After modifying sources under `examples/`, regenerate the bundle:

```bash
./builder -e examples/builder -o ./builder
```

The builder can rebuild itself. To test without overwriting, use a `build/` directory:

```bash
mkdir -p build
./builder -e examples/builder -o build/builder
```

