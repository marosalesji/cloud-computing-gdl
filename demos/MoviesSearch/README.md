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


## Demo 1: Docker

Esta parte del demo se enfoca en la creacion de la imagen de docker con el comando `build` y en el spin del contenedor
con el comando `run`.

Desde el directorio `demos/MoviesSearch`:

```bash
# Construir la imagen
docker build -t movies-search .

docker run \
  -p 8080:8080 \              # expone el puerto 8080 del contenedor en tu laptop
  -v ~/.aws:/root/.aws:ro \   # monta tus credenciales de AWS en modo solo lectura
  -e SECRET_NAME="videoclub/moviesearch/credentials" \  # nombre del secret en AWS
  -e AWS_REGION="us-east-1" \ # región de AWS
  movies-search
```

El subcomando `run` recibe los siguientes parámetros:
- `-p`: expone un puerto del contenedor en el host machine
- `-v`: monta el directorio de credenciales del host machine dentro del contenedor
- `-e`: pasar una variable de ambiente al contenedor

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

## Demo 2: Docker Hub

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

Ahora hay que realizar un cambio en el código del contenedor, por ejemplo cambiar el LIMIT de las queries a 1.

Queremos actualizar la imagen de este proyecto en Docker Hub, pero como es una imagen diferente hay que actualizar su versión,
esto se ve reflejado en la versión con la que etiquetamos la imagen y cuando hacemos el push.

```bash
# Reconstruir la imagen
docker build -t movies-search .

# Etiquetar como latest y v1.1
docker tag movies-search $DOCKER_HUB_USER/movies-search:latest
docker tag movies-search $DOCKER_HUB_USER/movies-search:v1.1

# Publicar
docker push $DOCKER_HUB_USER/movies-search:latest
docker push $DOCKER_HUB_USER/movies-search:v1.1
```

Ahora si vamos a Docker Hub vamos a ver 3 imágenes. Una es `latest` y `v1.1`, las cuales son iguales y regresan la query con un `LIMIT 1`.
Tambien tenemos `v1.0` la cual es la version anterior que regresa con el `LIMIT 20`.

Es posible descargar una version especifica con este comando.
```
docker pull $DOCKER_HUB_USER/movies-search:v1.0
docker pull $DOCKER_HUB_USER/movies-search:v1.1
```

## Referencias
- [Docker Comandos y troubleshooting](../../docs/linux/docker.md)
- [MovieLens Dataset](https://grouplens.org/datasets/movielens/)
- [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/)
