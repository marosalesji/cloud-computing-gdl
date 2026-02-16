# AlertaAlumnos

La universidad necesita avisar a todos los estudiantes si se suspenden clases por lluvia fuerte.
Se publica un solo mensaje y todos los suscriptores reciben el aviso por correo.


```
# Crear topic
aws sns create-topic --name alerta-clases

# Guardar ARN
TOPIC_ARN=$(aws sns create-topic \
  --name alerta-clases \
  --query TopicArn --output text)

# Suscribir correo
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint <correo@mail.com>

# Publicar alerta
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --message "lluvia_intensa|Clases suspendidas por tormenta|$(date '+%Y-%m-%d %H:%M:%S')"

```

Listar correos suscritos:

```
aws sns list-subscriptions-by-topic \
    --topic-arn $TOPIC_ARN \
    --query 'Subscriptions[].Endpoint' \
    --output json
```

Eliminar SNS topic:

```
aws sns delete-topic --topic-arn $TOPIC_ARN
```

## Pasos siguientes

Extiende el demo creando una aplicación en Python o TypeScript que:

1. Se despliegue en EC2.
2. Reciba mensajes desde Amazon SNS.
3. Guarde cada alerta en una base de datos RDS.

Tipos de catástrofe (ejemplos para GDL)
- lluvia_intensa
- inundacion
- temblor
- incendio_forestal

## Esquema de tabla

```sql
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    msg TEXT NOT NULL,
    type_catastrophe VARCHAR(50) NOT NULL
);

INSERT INTO alerts (timestamp, msg, type_catastrophe)
VALUES (NOW(), 'Clases suspendidas por tormenta', 'lluvia_intensa');

```

Tu aplicación debe:
- Suscribirse al topic de SNS.
- Parsear el mensaje.
- Insertarlo en RDS.

## Observaciones

Por lo pronto es válido usar el CLI para insertar datos.

El objetivo es que la aplicación consuma los datos desde SNS y los inserte en RDS.

Aún no vemos IAM, así que por lo pronto puedes utilizar tus credenciales de AWS CLI para la aplicación.
Hint: `~/.aws/credentials` es el archivo donde se guardan las credenciales de AWS CLI. El SDK de AWS lo lee automáticamente, así que no necesitas hacer nada especial para que tu aplicación tenga acceso a las credenciales.
