# Contribuir a Bash Builder

1. Hacer fork del repositorio.
2. Crear una rama con nombre descriptivo.
3. Hacer los cambios sobre los ficheros en `examples/`. El fichero `builder` en la raíz es el bundle generado y no se edita directamente.
4. Reconstruir el builder y verificar que no se rompe:
   ```bash
   ./builder -e examples/builder -o ./builder
   ```
5. Verificar con el ejemplo incluido:
   ```bash
   ./builder -e examples/listar.sh -o build/listar
   bash -n build/listar
   bash build/listar examples/
   ```
6. Incluir en el commit los fuentes modificados.
7. Abrir pull request explicando qué se cambió y por qué.

El proyecto está bajo GPLv3. Cualquier contribución se entiende publicada bajo la misma licencia.