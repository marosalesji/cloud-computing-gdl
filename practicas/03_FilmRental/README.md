# FilmRentals

Esta actividad se realiza en equipos de 3 integrantes. El objetivo es que
el equipo reflexione sobre el modelo serverless y las arquitecturas
event-driven estudiadas en el módulo 3.

El equipo debe utilizar al menos las siguientes tecnologías: Lambda, API
Gateway, Step Functions, RDS, Secrets Manager, SNS, EventBridge e IAM roles.

## Descripción del problema

Una tienda de renta de películas vintage quiere modernizar su sistema. El
catálogo es una réplica del dataset de MovieLens, el mismo que se utilizó
en el demo de MoviesCatalog. Sobre este catálogo el equipo construirá un
sistema serverless que permita buscar películas, rentar una, consultar el
estado de las rentas de un usuario y recibir una alerta cuando una renta
está a punto de vencer.

Reglas del negocio:

- Una película se renta por máximo 1 semana y no es posible extender el plazo.
- Un usuario no puede tener más de 2 rentas activas al mismo tiempo.
- A partir de 3 días antes del vencimiento, el sistema notifica al usuario
  diariamente con cuántos días le quedan.

## Setup

Antes de desarrollar los endpoints, el equipo debe completar el setup
inicial. Es necesario que utilicen scripts de bash, también se recomienda
documentar este proceso en el README.

1. Crear una instancia RDS PostgreSQL siguiendo el mismo procedimiento del
   demo MoviesCatalog y cargar el CSV de películas en la tabla `movies`.
2. Crear una instancia EC2 únicamente para conectarse a RDS y ejecutar el
   setup inicial. Esta instancia no corre la aplicación.
3. Guardar en Secrets Manager las credenciales de RDS (usuario y password)
   y el hostname de la instancia. Se deben usar los siguientes nombres:
   - `filmrentals/rds/host`
   - `filmrentals/rds/credentials`
4. Crear las siguientes tablas:

```sql
CREATE TABLE rentals (
    id          SERIAL PRIMARY KEY,
    movie_id    INTEGER NOT NULL REFERENCES movies(movieId),
    user_id     VARCHAR(50) NOT NULL,
    rented_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '7 days',
    returned_at TIMESTAMP
);

CREATE TABLE users (
    id      SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    name    VARCHAR(100) NOT NULL,
    email   VARCHAR(100) NOT NULL
);
```

Una vez creadas las tablas, ejecutar el script de usuarios de prueba:

```bash
bash infra/scripts/insert_fake_users.sh
```

El script inserta 3 usuarios con `user_id` del 1 al 3. Antes de correrlo,
edita los correos en el script para usar direcciones reales, ya que esos
mismos correos se usarán para las suscripciones de SNS en las alertas de
vencimiento.

El sistema no contempla la creación ni eliminación de usuarios a través de
la API. Para efectos de esta práctica se asume que los usuarios ya existen
en la base de datos.

**Importante:** `insert_fake_users.sh` puede contiene correos reales del
equipo. No subas este archivo a GitHub. Agrégalo a `.gitignore` o usa
direcciones temporales generadas.

## Requisitos

- No debe haber credenciales hardcodeadas en ningún archivo del repositorio.
  Las Lambdas deben obtener las credenciales de RDS desde Secrets Manager
  en tiempo de ejecución, usando el IAM role LabRole.
- La mayor parte de la configuración de recursos debe automatizarse con
  scripts de bash ubicados en `infra/scripts/`.
- El código de las Lambdas va en `src/`.
- La definición de la máquina de estados va en `infra/`.
- El README debe ser conciso. La documentación adicional va en `docs/`.
- Si el equipo decide incluir un frontend, va en `frontend/`.

## Endpoints

Todos los endpoints se resuelven con API Gateway y Lambda.

### GET /movies?name=toy

Busca películas cuyo título contenga el término buscado, sin distinguir
mayúsculas de minúsculas. Por cada resultado indica si está actualmente
rentada, es decir, si tiene una renta activa sin `returned_at`.

Respuesta esperada:

```json
[
  { "movie_id": 1, "title": "Toy Story (1995)", "is_rented": false },
  { "movie_id": 3114, "title": "Toy Story 2 (1999)", "is_rented": true }
]
```

### POST /rent

Body: `{ "movie_id": 123, "user_id": "1" }`

Inicia un proceso de renta a través de una Step Function con invocación
asíncrona. La máquina de estados ejecuta los siguientes pasos en orden:

1. `CheckMovieExists`: verifica que el `movie_id` exista en la tabla
   `movies`. Si no existe, termina con error.
2. `CheckMovieAvailable`: verifica que la película no tenga una renta
   activa. Si está rentada, termina con error.
3. `CheckUserLimit`: verifica que el usuario no tenga 2 o más rentas
   activas. Si las tiene, termina con error.
4. `CreateRental`: inserta el registro en `rentals`.

Cada estado de error debe loggear un mensaje descriptivo el cual se podrá
ver a través de CloudWatch para debuggear.

### GET /status/{user_id}

Devuelve todas las rentas activas del usuario, es decir, las que no tienen
`returned_at`. La respuesta incluye el título de la película, la fecha de
inicio y la fecha de expiración.

## Alertas de vencimiento

Configurar una regla de EventBridge que dispare una Lambda una vez al día
en el horario que el equipo elija. Esta Lambda consulta todas las rentas
activas cuyo `expires_at` sea dentro de los próximos 3 días y publica un
mensaje en SNS por cada renta próxima a vencer, indicando la película y
cuántos días faltan.

El topic de SNS debe llamarse `rentals-expiring-soon`. Cada integrante
del equipo debe tener una suscripción de email en ese topic asociada a
su `user_id`, de modo que cada quien reciba únicamente las alertas de
sus propias rentas.

Para el demo, cada integrante simula ser un usuario distinto: el alumno 1
usa `user_id` 1, el alumno 2 usa `user_id` 2 y el alumno 3 usa `user_id`
3. Al correr la Lambda, solo los usuarios con rentas próximas a vencer
deben recibir el correo de alerta.

Nota: cada suscripción de email requiere confirmación. AWS envía un correo
con un enlace que debe aceptarse antes de que la suscripción quede activa.

Hint: investiga SNS Filter Policies y cómo incluir MessageAttributes al
momento de publicar un mensaje. Con esas dos piezas pueden lograr que cada
suscripción reciba únicamente los mensajes que le corresponden.

## Ejemplos de uso

Los siguientes comandos asumen que `API_URL` contiene la URL base del API
Gateway. Por ejemplo:

```bash
export API_URL=https://<api-id>.execute-api.us-east-1.amazonaws.com
```

### Buscar películas

```bash
curl "$API_URL/movies?name=toy"

# Resultado esperado
# [
#   { "movie_id": 1,    "title": "Toy Story (1995)",    "is_rented": false },
#   { "movie_id": 3114, "title": "Toy Story 2 (1999)",  "is_rented": true  }
# ]
```

### Rentar una película

```bash
curl -X POST "$API_URL/rent" \
  -H "Content-Type: application/json" \
  -d '{ "movie_id": 1, "user_id": "1" }'

# Resultado esperado (renta exitosa)
# {
#   "execution_arn": "arn:aws:states:us-east-1:...",
#   "status": "RUNNING"
# }

# POST /rent es asíncrono, así que verificamos si la renta fue exitosa
# consultando el status del usuario
curl "$API_URL/status/1"

# Resultado esperado una vez que la Step Function termina
# [
#   {
#     "rental_id": 1,
#     "title": "Toy Story (1995)",
#     "rented_at": "2026-03-12T10:00:00",
#     "expires_at": "2026-03-19T10:00:00"
#   }
# ]
```

### Consultar rentas activas de un usuario

```bash
curl "$API_URL/status/1"

# Resultado esperado
# [
#   {
#     "rental_id": 1,
#     "title": "Toy Story (1995)",
#     "rented_at": "2026-03-12T10:00:00",
#     "expires_at": "2026-03-19T10:00:00"
#   }
# ]
```

### Casos de error

Intentar rentar una película que ya está rentada:

```bash
curl -X POST "$API_URL/rent" \
  -H "Content-Type: application/json" \
  -d '{ "movie_id": 1, "user_id": "2" }'

# Resultado esperado
# {
#   "error": "Movie is not available",
#   "movie_id": 1
# }
```

Intentar rentar una tercera película con el mismo usuario:

```bash
curl -X POST "$API_URL/rent" \
  -H "Content-Type: application/json" \
  -d '{ "movie_id": 5, "user_id": "1" }'

# Resultado esperado
# {
#   "error": "User has reached the rental limit",
#   "user_id": "1"
# }
```

## Entregables

### Reporte en PDF

- Portada con nombres, nombre de la actividad, materia y fecha
- Descripción del sistema (parafraseada, no copiar el enunciado)
- Diagrama de arquitectura con todos los componentes y sus interacciones
- Descripción del diagrama (200 a 300 palabras)
- Respuestas a las preguntas del final
- Link al repositorio de GitHub
- Link al video

### Repositorio de GitHub

- Código de cada Lambda en `src/`
- Definición de la Step Function en `infra/`
- Scripts de setup en `infra/scripts/`
- README con instrucciones de despliegue

### Video (máximo 10 minutos)

Todos los integrantes participan. El video debe mostrar:

- Secrets Manager con los secretos creados
- El topic de SNS con las suscripciones de cada integrante configuradas
- El flujo completo: buscar película, rentarla, consultar el status,
  intentar rentar una película ya rentada (debe fallar) e intentar rentar
  una tercera película con el mismo usuario (debe fallar)
- La Step Function ejecutándose en la consola de AWS
- La notificación de EventBridge llegando al correo del equipo
- Cada integrante explica la parte que desarrolló

## Preguntas a responder en el reporte

1. ¿Por qué las credenciales de RDS no deben estar en el código de la
   Lambda? ¿Qué riesgo concreto resuelve Secrets Manager en este sistema?

2. El endpoint de renta usa Step Functions en lugar de concentrar toda la
   lógica en una sola Lambda. ¿Qué ventaja tiene este diseño? ¿En qué
   escenario sería suficiente con una sola Lambda?

3. El sistema de alertas notifica a cada usuario individualmente usando
   SNS Filter Policies. ¿Cómo escalaría este diseño si el sistema tuviera
   miles de usuarios? ¿Qué limitaciones tendría SNS en ese escenario y
   qué alternativa usarías?

## Referencias

- Demo MoviesCatalog: https://github.com/marosalesji/cloud-computing-gdl/tree/main/demos/MoviesCatalog
- Demo ReportGenerator: https://github.com/marosalesji/cloud-computing-gdl/tree/main/demos/ReportGenerator
- Demo AlertaAlumnos: https://github.com/marosalesji/cloud-computing-gdl/tree/main/demos/AlertaAlumnos
