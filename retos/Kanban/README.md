# Kanban

Para esta actividad deberás desarrollar un backend en la nube para administrar tareas siguiendo el sistema de trabajo
[kanban](https://es.wikipedia.org/wiki/Kanban).

Kanban es un sistema de control de actividades que modela el flujo de trabajo mediante tareas que avanzan entre
distintos estados.

Una tarea dentro del sistema se denomina `card` y puede encontrarse únicamente en uno de los siguientes estados:
`backlog`, `doing` o `done`.

## Creación de tarjetas

Las tareas se crean mediante un endpoint `POST /card`. El sistema debe generar un ID único para cada card creada.

Los campos requeridos son:
- titulo (máximo 50 caracteres)
- descripcion (máximo 500 caracteres)
- fecha_limite
- fecha_creado
- estado

Los campos fecha_limite y fecha_creado deben enviarse como timestamps en formato ISO 8601 en UTC, por ejemplo:
`2026-03-12T23:59:00Z` (YYYY-MM-DDTHH:MM:SSZ)

```bash
curl -X POST https://<api-url>/card \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "Hacer practica 3",
    "descripcion": "Es la app de la cafeteria",
    "fecha_limite": "2026-03-14T23:59:00Z",
    "fecha_creado": "2026-03-04T18:00:00Z",
    "estado": "backlog"
  }'
```

## Lectura de tareas

Para obtener la lista de tareas se utiliza un endpoint `GET /card`. La respuesta debe incluir todas las cards
registradas junto con su ID único.

```bash
curl -X GET https://<api-url>/card
```

## Actualización de tareas

Las tareas se actualizan mediante `PUT /card/{id}`.

Solo está permitido modificar los siguientes campos:
- `fecha_limite`
- `estado`

```
curl -X PUT https://<api-url>/card/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "fecha_limite": "2026-03-12T23:59:00Z",
    "estado": "doing"
  }'

```

## Eliminación de tareas

Una tarea puede eliminarse utilizando `DELETE /card/{id}`.

```shell
curl -X DELETE https://<api-url>/card/{id}
```

## Requerimientos

El sistema no debe crear ni actualizar una card en los siguientes casos:
- El timestamp enviado no cumple con el formato ISO 8601.
- El estado enviado no es uno de los valores permitidos: `backlog`, `doing`, `done`.

En estos casos, el sistema debe rechazar la operación, no crear ni actualizar la card y regresar un mensaje indicando el
motivo del rechazo. La aplicación no debe fallar ni generar efectos secundarios.

La aplicación debe desarrollarse utilizando el lenguaje de programación de tu elección y únicamente tecnologías de AWS
vistas en clase o directamente relacionadas con ellas.

## Preguntas a responder

- ¿Qué tecnología elegiste para el cómputo y por qué?
- ¿Qué tecnología elegiste para almacenamiento y por qué?
- ¿Qué tecnologías utilizarías para notificar al usuario que una tarea con estado `backlog` o `doing` está próxima a
  vencer (por ejemplo, al día siguiente)?
