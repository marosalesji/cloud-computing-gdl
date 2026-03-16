# Práctica 2: Cafetería

Una cafetería recibe demasiados pedidos a la hora pico. Para no colapsar la caja,
cada pedido se mete en una cola y los baristas procesan las órdenes conforme pueden.
El objetivo de esta práctica es implementar ese flujo guardando cada orden en una
base de datos.

## Arquitectura

- **EC2** — corre el consumer que hace polling de la queue y guarda las órdenes en RDS
- **SQS** — transporta los mensajes entre el producer y el consumer
- **RDS** — almacena las órdenes de compra

No se requiere frontend ni API. El producer se simula con AWS CLI.

## Formato de mensajes

Los mensajes en SQS tienen el siguiente formato:
```
<Tipo de café>|<timestamp>
```

Por ejemplo:
```
Latte|2026-02-16 13:39:45
```

## Base de datos
```sql
CREATE TABLE coffee_orders (
    id           SERIAL PRIMARY KEY,
    timestamp    TIMESTAMP NOT NULL,
    coffee_type  VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'created'
);
```

Todas las órdenes creadas en esta práctica tendrán estado `created`. Los estados
`brewing` y `delivered` no son parte de esta actividad.

## Comportamiento esperado

- El consumer hace polling infinito de la queue
- Al recibir un mensaje, parsea el tipo de café y el timestamp
- Inserta la orden en RDS con estado `created`
- Elimina el mensaje de la queue después de procesarlo exitosamente para evitar duplicados

## Entregables

### Reporte en PDF

- Portada con nombre del alumno, nombre de la actividad, materia y fecha
- Descripción del problema
  - Nombre de la aplicación
  - Problema que busca resolver
- Diagrama de arquitectura con los componentes de AWS y tu programa, mostrando cómo interactúan
- Descripción del diagrama (200 a 300 palabras)
- Link al repositorio de GitHub
- Link al video
- Referencias si las hay

### Repositorio de GitHub

- Código del proyecto — claro, entendible y funcional
- README con explicación breve del repositorio

### Video (5 a 10 minutos)

El video debe mostrar la aplicación corriendo en la nube, no en local. Debe incluir:

- La instancia de EC2 encendida en la consola de AWS
- La queue de SQS creada
- Envío de 5 mensajes con tipos de café diferentes usando AWS CLI
- Los datos llegando a RDS sin duplicados — puedes conectarte a RDS desde tu laptop para hacer queries y demostrarlo
- Explicación breve de qué hace la aplicación y cómo utiliza los servicios de AWS

## Referencias

- Demo Cafetería: [Cafeteria](../../demos/Cafeteria)
- Demo EC2 + S3: [MoviesCatalog](../../demos/MoviesCatalog)
