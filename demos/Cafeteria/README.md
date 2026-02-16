# Cafeteria

A las 12:00 pm la cafetería recibe demasiados pedidos.
Para no colapsar la caja, cada pedido se mete en una cola.
Los baristas procesan pedidos conforme pueden.
Así evitamos saturación y pérdida de órdenes.

```
# Crear cola
aws sqs create-queue --queue-name cafeteria-queue

# Obtener URL
QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name cafeteria-queue \
  --query QueueUrl --output text)

# Enviar pedidos
aws sqs send-message --queue-url $QUEUE_URL --message-body "Latte|$(date '+%Y-%m-%d %H:%M:%S')"
sleep 3
aws sqs send-message --queue-url $QUEUE_URL --message-body "Capuccino|$(date '+%Y-%m-%d %H:%M:%S')"
sleep 5
aws sqs send-message --queue-url $QUEUE_URL --message-body "Espresso|$(date '+%Y-%m-%d %H:%M:%S')"

# Barista recibe pedido
aws sqs receive-message --queue-url $QUEUE_URL

# Borrar pedido procesado, debes tomar el ReceiptHandle del mensaje recibido para borrarlo
aws sqs delete-message --queue-url $QUEUE_URL --receipt-handle <RECEIPT_HANDLE>
```

Tip: de la siguiente forma puedes capturar la respuesta del
receive-message para obtener el ReceiptHandle y luego usarlo
para borrar el mensaje:


```
RESPONSE=$(aws sqs receive-message --queue-url $QUEUE_URL --output json)
echo "Response: $RESPONSE"

RECEIPT_HANDLE=$(echo "$RESPONSE" | jq -r '.Messages[0].ReceiptHandle')
echo "Receipt Handle: $RECEIPT_HANDLE"

aws sqs delete-message --queue-url $QUEUE_URL --receipt-handle "$RECEIPT_HANDLE"
```

Eliminar queue

```
aws sqs delete-queue --queue-url $QUEUE_URL
```

## Pasos siguientes
Ahora debes convertir el demo en una aplicación real.

1. Desarrolla una app en Python o TypeScript.
2. Despliega la app en una instancia EC2.
3. La app debe:
   - Consumir mensajes desde Amazon SQS.
   - Extraer `coffee_type` y `timestamp`.
   - Insertar el pedido en RDS con `order_status = 'created'`.

Cada pedido debe registrarse inicialmente con estado `created`,
simulando que apenas fue recibido por la cafetería y
aún no ha sido preparado.

### Esquema de tabla

```sql
CREATE TABLE coffee_orders (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    coffee_type VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'created'
);
```

Tu aplicación debe:
- Poolear mensajes de SQS.
- Parsear el mensaje para obtener `coffee_type` y `timestamp`.
- Insertar el pedido en la tabla coffee_orders con order_status = 'created'.
- Manejar errores de conexión a RDS y SQS.
- Asegurate de que los mensajes se borren de SQS después de ser procesados exitosamente para evitar duplicados.

## Observaciones

Por lo pronto es válido usar el CLI para insertar datos.

El objetivo es que la aplicación consuma los datos desde SQS y los inserte en RDS.

Aún no vemos IAM, así que por lo pronto puedes utilizar tus credenciales de AWS CLI para la aplicación.
Hint: `~/.aws/credentials` es el archivo donde se guardan las credenciales de AWS CLI. El SDK de AWS lo lee automáticamente, así que no necesitas hacer nada especial para que tu aplicación tenga acceso a las credenciales.
