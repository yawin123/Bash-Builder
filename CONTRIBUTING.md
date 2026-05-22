# Contributing to Bash Builder

1. Fork the repository.
2. Create a branch with a descriptive name.
3. Make changes to the files under `examples/`. The `builder` file at the root is the generated bundle and should not be edited directly.
4. Rebuild the builder and verify it still works:
   ```bash
   ./builder -e examples/builder -o ./builder
   ```
5. Verify with the included example:
   ```bash
   ./builder -e examples/listar.sh -o build/listar
   bash -n build/listar
   bash build/listar examples/
   ```
6. Include the modified source files in your commit.
7. Open a pull request describing what changed and why.
