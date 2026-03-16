# Docker

## Comandos útiles

```bash
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores
docker ps -a

# Ver todas las imágenes locales
docker images

# Entrar al contenedor con bash
docker exec -it <container-id> bash

# Detener el contenedor
docker container stop <container-id>

# Detener y eliminar el contenedor
docker rm -f <container-id>

# Build sin caching
docker build --no-cache -t <nombre_de_imagen> .
```

## Troubleshooting

### Error de red al hacer build

Si al correr `docker build` aparece un error como `operation not supported` o `failed to create endpoint`, prueba agregando `--network host`:
```bash
docker build --network host -t movies-search .
```

Si el problema persiste, intenta reiniciar el daemon de Docker:
```bash
sudo systemctl restart docker
```
