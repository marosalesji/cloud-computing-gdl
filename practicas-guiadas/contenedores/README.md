# Practica guiada: contenedores

## 1. Corre Hello World

Corre el siguiente comando

```bash
docker run hello-world
```
Docker descarga la imagen hello-world de Docker Hub, crea y corre un
contenedor.

Puedes ver la imagen descargada con
```bash
docker images
```
Tambien puedes ver el contenedor
```bash
docker ps
```
- ¿por qué no sale nada?

Asi podemos ver la ayuda
```bash
docker ps --help
```

## 2. Descarga imágenes

```bash
docker image pull alpine
docker image pull ubuntu:24.04
```
Puedes buscar en docker hub más imágenes

- https://hub.docker.com/_/ubuntu/tags
- https://hub.docker.com/r/opensuse/leap
- https://hub.docker.com/r/localstack/localstack

## 3. Corre contenedores

A partir de una imagen descargada puedes lanzar un contenedor

```bash
docker run  ubuntu:24.04
docker run -it ubuntu:24.04
```
- ¿qué diferencia tienen los dos comandos de arriba?

## 4. Revisa los siguientes proyectos

Docker es una buena herramienta que te permite explorar proyectos y hacer
pruebas sin ensuciar tu computadora. ¿por qué?

### Jupyter

- https://hub.docker.com/r/jupyter/datascience-notebook

```bash
docker run -it --rm -p 8888:8888 jupyter/datascience-notebook
```
- ¿cuantas imagenes de docker tengo descargadas?

Haz la gráfica de un coseno

```python
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.DataFrame({
    "tiempo": np.linspace(0, 4 * np.pi, 200),
    "valor": np.cos(np.linspace(0, 4 * np.pi, 200))
})

sns.lineplot(data=df, x="tiempo", y="valor")
plt.title("Coseno")
plt.show()
```

### Postgres

- https://hub.docker.com/_/postgres

```bash
docker pull postgres

docker pull postgres:18.3

docker run --name postgres-container -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydb -p 5432:5432 -d postgres:16.9

docker exec -it postgres-container psql -U myuser -d mydb
```
- ¿cuantas imagenes de postgres tengo descargadas?

Puedes verificar el hash

```bash
docker inspect postgres:<tag> --format='{{.Id}}'
```

Corre las siguientes queries

```sql
CREATE TABLE empleados (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(50),
    apellido    VARCHAR(50),
    departamento VARCHAR(50),
    antiguedad INT
);

INSERT INTO empleados (nombre, apellido, departamento, antiguedad)
VALUES ('Carlos', 'Mendoza', 'Ingeniería', 7);

SELECT nombre, apellido, departamento, antiguedad
FROM empleados
WHERE antiguedad > 5;
```

## 5. Containarizar una app

Significa que vamos a empaquetar la applicación con todo lo que necesita para
correr.

¿qué hace la `app1`?

¿qué hace el archivo `Dockerfile`?

```bash
cd app1
docker build -t app1 .
docker run -p 8000:8000 app1
```
¿qué pasa si se borra el contenedor?

¿qué hace la `app2`?

Identifica las diferencias entre estos dos proyectos

```bash
cd app2
docker build -t app2 .
docker run -p 8000:8000 -v app2-data:/data app2
```

Mientras app2 está corriendo, investiga su contenido

```bash
docker exec -it <nombre-del-contenedor> bash
```
El comando anterior ejecuta bash dentro del contenedor, por eso nos regresa su
terminal.

¿dónde está el volumen app2-data en el contenedor?

¿y dónde está el volumen en el host?

```bash
docker volume inspect app2-data
```

Docker no elimina sus componentes y esto podría causar un problema de
almacenamiento en tu computadora. El comando prune ayuda a eliminar lo que no
está en uso, en este caso volúmenes.

```bash
docker volume ls
docker volume prune
```

## 6. Docker compose

Ahora veamos la app3 ¿qué diferencias hay?

```bash
cd app3
docker compose up --build
```

¿qué hizo?

¿cuántos contenedores creó?

¿qué hacemos para conectarnos a la base de datos?

Podemos ver los logs asi

```
docker container logs app3-app-1
```

```bash
docker compose down -v
```

## 7. Docker Hub

Vamos a empujar app1 a Docker Hub

```
export DOCKER_HUB_USER=<usuario>

docker build -t $DOCKER_HUB_USER/app1:v0.1 .
docker push $DOCKER_HUB_USER/app1:v0.1
```
- ¿cómo puede descargarla alguien más?

## Referencias
- https://www.datacamp.com/blog/docker-commands
- https://www.datacamp.com/blog/docker-container-images-for-machine-learning-and-ai
- https://sliplane.io/blog/how-to-run-postgres-in-docker
- https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/
