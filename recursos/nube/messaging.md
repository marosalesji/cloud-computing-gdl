# AWS messaging services

## SQS

```
export SQSURL=""
aws sqs send-message --queue-url $SQSURL --message-body "This is a test message"

```

Puedes recuperar de 1 a 10 mensajes a la vez, y el mensaje se eliminará de la cola después de ser recuperado.

Si deseas recuperar un mensaje sin eliminarlo, puedes usar el parámetro `--visibility-timeout` para establecer un tiempo de espera durante el cual el mensaje no estará disponible para otros consumidores.

```

aws sqs receive-message --queue-url $SQSURL --max-number-of-messages 10
```

Como es un sistema distribuido, no hay garantía de que el consumer reciba y procese correctamente el mensaje.

Por ejemplo, si el consumer tiene un error de conectividad.

Mientras el mensaje esté dentro del tiempo de visibility timeout, el mensaje no estará disponisble para otros consumidores.

Es responsabilidad del consumer eliminar el mensaje de la cola después de procesarlo correctamente, pasado el tiempo de visibility timeout, el mensaje volverá a estar disponible para otros consumidores.
De esta manera se maneja la tolerancia a fallos y se asegura que los mensajes no se pierdan.

El default de visibility timeout es de 30 segundos.
Lo mínimo son 0 segundos y lo máximo son 12 horas.
