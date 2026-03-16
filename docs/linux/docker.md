# Docker

## Comandos útiles

### Contenedores
```bash
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores (incluyendo detenidos)
docker ps -a

# Entrar al contenedor con bash
docker exec -it <container-id> bash

# Ver logs del contenedor
docker logs <container-id>

# Ver logs en tiempo real
docker logs -f <container-id>

# Detener el contenedor
docker container stop <container-id>

# Detener y eliminar el contenedor
docker rm -f <container-id>

# Eliminar todos los contenedores detenidos
docker container prune
```

### Imágenes
```bash
# Ver todas las imágenes locales
docker images

# Eliminar una imagen local
docker rmi <nombre-imagen>:<tag>

# Eliminar una imagen local por ID
docker rmi <image-id>

# Eliminar todas las imágenes sin usar
docker image prune

# Build sin caching
docker build --no-cache -t <nombre_de_imagen> .
```

### Docker Hub
```bash
# Login
docker login

# Etiquetar imagen
docker tag <imagen-local> <usuario>/<imagen>:<tag>

# Publicar imagen
docker push <usuario>/<imagen>:<tag>

# Descargar una versión específica
docker pull <usuario>/<imagen>:<tag>
```

## Troubleshooting

### Error de red al hacer build o run

Si aparece un error como `operation not supported` o `failed to create endpoint`, prueba agregando `--network host`:
```bash
docker build --network host -t <nombre-imagen> .

docker run --network host \
  -v ~/.aws:/root/.aws:ro \
  <nombre-imagen>
```

Si el problema persiste, intenta reiniciar el daemon de Docker:
```bash
sudo systemctl restart docker
```
