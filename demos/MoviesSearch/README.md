# MoviesSearch

Sistema de búsqueda de películas por género y título. La app corre en un contenedor Docker en tu computadora local y
hace consultas a una base de datos RDS en AWS.

En este demo aprenderás:
- Qué es una imagen y qué es un contenedor
- Cómo construir una imagen a partir de un Dockerfile
- Qué beneficios tiene empaquetar una app en un contenedor
- Cómo montar volúmenes en un contenedor
- Cómo publicar una imagen en Docker Hub
- Cómo actualizar una imagen cuando hay cambios en el código

## Preparación

### Requisitos

- Docker instalado
- AWS CLI configurado con credenciales válidas en `~/.aws/credentials`
- RDS con el dataset de MovieLens cargado (ver `scripts/setup-rds.sh` y `scripts/setup-movies-db.sh`)

### Scripts

Antes de crear la aplicación en el contenedor de docker, es necesario crear el recurso de la base de datos RDS
y cargar el dataset de MovieLens.

- `scripts/setup-rds.sh` - crea la instancia RDS en AWS
- `scripts/setup-movies-db.sh` - crea la tabla movies y carga el dataset de MovieLens
- `scripts/setup-secrests.sh` - crea los secrets para RDS


## Demo: Docker

Esta parte del demo se enfoca en la creacion de la imagen de docker con el comando `build` y en el spin del contenedor
con el comando `run`.

Desde el directorio `demos/MoviesSearch`:

```bash
# Construir la imagen
docker build -t movies-search .

# Correr el contenedor montando las credenciales de AWS
docker run -p 8080:8080 \
  -v ~/.aws:/root/.aws:ro \
  -e SECRET_NAME="videoclub/moviesearch/credentials" \
  -e AWS_REGION="us-east-1" \
  movies-search
```

El subcomando `run` recibe los siguientes parámetros:
- `-p`: conectar un puerto del host machine con el contenedor
- `-v`: conectar como un volumen en el contenedor un path en el host machine
- `-e`: pasar una variable de ambiente al contenedor

El flag `-v ~/.aws:/root/.aws:ro` monta el directorio de credenciales de tu laptop dentro del contenedor en modo de solo
lectura. Así el contenedor puede autenticarse con AWS sin que tengas que copiar y pegar credenciales.

Probar la app:
```bash
# Buscar por género
curl "http://localhost:8080/movies?genre=comedy"

# Buscar por título
curl "http://localhost:8080/movies?title=toy"

# Combinar género y título
curl "http://localhost:8080/movies?genre=comedy&title=toy"

# Health check
curl http://localhost:8080/health
```

## Demo: Docker Hub

Para subir la imagen construida en la primera parte de este demo a Docker Hub es necesario tener cuenta primero y después hacer login.

```bash
docker login
```

Después publicamos la imagen que tenemos como `:latest`

```bash
export DOCKER_HUB_USER="<usuario>"

# Etiquetar la imagen con tu usuario de Docker Hub
docker tag movies-search $DOCKER_HUB_USER/movies-search:latest

# Podemos ver la imagen etiquetada
docker images

# Publicar
docker push $DOCKER_HUB_USER/movies-search:latest
```

Publicar la imagen misma imagen como `v1.0`

```bash
docker tag movies-search $DOCKER_HUB_USER/movies-search:v1.0
docker push $DOCKER_HUB_USER/movies-search:v1.0
```

Ahora hay que realizar un cambio en el código del contenedor, por ejemplo cambiar el limit de las queries a 1.


## Actualizar la imagen después de cambios
```bash
# Reconstruir la imagen
docker build -t movies-search .

# Volver a etiquetar y publicar
docker push $DOCKER_HUB_USER/movies-search:latest
```

## Comandos útiles
```bash
# Ver contenedores corriendo
docker ps

# Ver todas las imágenes locales
docker images

# Entrar al contenedor con bash
docker exec -it <container-id> bash

# Detener y eliminar el contenedor
docker rm -f <container-id>
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

## Referencias
- [MovieLens Dataset](https://grouplens.org/datasets/movielens/)
- [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/)
