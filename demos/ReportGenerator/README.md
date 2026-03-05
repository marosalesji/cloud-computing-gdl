# Reporde de Vuelo

ReporteVuelos es una aplicación serverless que genera un reporte de vuelos que han despegado en un día determinado. La
aplicación utiliza AWS API Gateway como punto de entrada, AWS Step Functions para orquestar el flujo y AWS Lambda para
ejecutar la lógica de negocio.

La información de los vuelos se obtiene desde Amazon DynamoDB, que almacena registros de vuelos que han despegado en
tiempo real.

## Recursos de la nube

Se crean los recursos necesarios usando AWS CLI y Step Functions:
- DynamoDB: tabla RegistroDespegue.
- S3: bucket para almacenar reportes.
- Lambdas: validate_reporte, buscar_vuelos, crear_reporte, guardar_reporte.
- Step Function: ReporteVuelosStateMachine.
- API Gateway: endpoint /reporte.

Vamos a crear los siguientes utilizando AWS CLI:

```shell
./scripts/setup_dynamodb.sh
./scripts/create_s3_bucket.sh
./script/package_and_create_lambdas.sh
./script/create_and_configure_api_gateway.sh
```

Para crear el workflow en step functions usaremos AWS Management Console, se llama
`ReporteVuelosStateMachine` y podemos usar `scripts/state_machine.json` como base.

Es necesario ponerle `LabRole` para que pueda usar las lambdas. También hay que configurar el
ARN del workflow como variable de ambiente en validate_reporte.

[Amazon state language ASL](https://states-language.net/)

## Flujo de la aplicación

Este endpoint permite generar un reporte para un día específico. El flujo de ejecución es el siguiente:

1. API Gateway recibe la solicitud HTTP del cliente y la envía a una Lambda validate_reporte.
  - Valida que el payload incluya los campos requeridos: fecha en formato YYYY-MM-DD.
  - Si la validación falla, devuelve un error 400.
  - Si la validación es correcta, inicia la Step Function ReporteVuelosStateMachine.
2. Step Function orquesta las siguientes Lambdas:
  - BuscarVuelos:
    - Consulta la tabla DynamoDB RegistroDespegue.
    - Extrae todos los vuelos cuya fecha_salida coincida con la fecha solicitada y que ya hayan despegado al momento
(UTC).
  - CrearReporte:
    - Recibe la lista de vuelos.
    - Formatea los datos de manera legible en un documento de texto. Por ejemplo:
        ```
        Vuelos despegados el 2026-03-05 (UTC):
        - FL001 Ciudad de México → Guadalajara 08:00
        - FL002 Ciudad de México → Monterrey 12:30
        ```
  - GuardarReporte:
    - Guarda el archivo en un bucket de S3 preconfigurado.
    - Devuelve la ubicación (s3://bucket/reporte_2026-03-05.txt) como resultado final.
3. La Step Function termina cuando el reporte se ha generado y guardado. La Lambda inicial devuelve al cliente un
executionArn o un mensaje indicando que el reporte se está generando.

## Código

La entrada de la aplicación es a través del endpoint POST /reporte, el payload esperado es:

```shell
{"fecha": "2026-03-05"}
```
fecha es la fecha para la que se quiere generar el reporte, en formato YYYY-MM-DD (UTC).

Las funciones Lambda se organizan por responsabilidad:

`validate_reporte`: Valida el payload del cliente. Inicia la Step Function si la fecha es correcta.
`buscar_vuelos`: Consulta DynamoDB y filtra vuelos que han despegado en la fecha solicitada.
`crear_reporte`: Formatea los datos de manera legible en un archivo de texto.
`guardar_reporte`: Guarda el archivo en S3.

Cada Lambda realiza una única responsabilidad, lo que facilita pruebas y despliegue.

## Validación

```shell
API_GATEWAY_URL=""
curl -X POST $API_GATEWAY_URL/demo/reporte -H "Content-Type: application/json" -d '{"fecha":"2026-03-10"}'
```

El reporte aparecera en S3 listo para su consulta.

## Eliminar recursos

Para limpiar los recursos del demo:

-API Gateway
-State Machine de Step Functions
-Funciones Lambda
-Tabla DynamoDB
-Bucket de S3

Esto evita dependencias activas y mantiene orden en la nube.
