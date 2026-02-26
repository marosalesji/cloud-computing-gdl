# Thumbnail generator

Un thumbnail es una versión reducida de una imagen. Esta aplicación funciona para generar thumbnails
de imágenes de entrada.

El flujo de la aplicación serverless es:

1. Un usuario utiliza `AWS CLI` para cargar una imagen en un bucket S3
2. El evento de upload hace trigger a una lambda
3. La lambda llamada thumbnail-generator corre un código de python que convierte la imagen en un
   thumbnail y lo guarda en S3

## Estructura del proyecto

```
├── README.md
├── scripts
│   ├── package.basic.sh
│   └── package.optimized.sh
└── src
    └── thumbnail-generator
        ├── lambda_function.py
        └── requirements.txt
```

## Recursos en la nube

Para desarrollar este proyecto es necesario crear dos buckets `S3` y una función `Lambda`.

### Buckets S3

```
# S3 bucket input-images
aws s3 mb s3://ccg1-input-images --region us-east-1


# S3 bucket thumbnail-images
aws s3 mb s3://ccg1-thumbnail-images --region us-east-1

```

### Lambda

Lambda es un recurso Function As A Service (FaaS) que ofrece AWS.

Para crearla es necesario cargar el código de la función para que pueda ejecutarlo. Existen tres
formas de subir el código a una lambda.

1. En la consola de AWS utilizando la interfaz gráfica
2. Subir un archivo zip que incluya el código y sus dependencias
3. Subir una imagen de Docker

Para este demo vamos a utilizar la segunda forma ya que nuestro código tiene dependencias de las
librerias `boto3` y `Pillow`.

```
# Empaquetar la funcion
# [Alumno] Revisa el script con calma. ¿Qué hace este script?
# [Alumno] ¿Por qué es necesario empaquetar?
./scripts/package.basic.sh

# Obten el ARN de LabRole del servicio IAM
LAB_ROLE_ARN=$(aws iam get-role --role-name LabRole --query 'Role.Arn' --output text)

# Crear la lambda
# [Alumno] ¿Por qué necesitamos LabRole?
aws lambda create-function \
    --function-name thumbnail-generator \
    --runtime python3.14 \
    --role $LAB_ROLE_ARN \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://thumbnail-generator.zip

# Darle permiso a S3 para invocar la funcion
aws lambda add-permission \
  --function-name thumbnail-generator \
  --statement-id s3-trigger \
  --action lambda:InvokeFunction \
  --principal s3.amazonaws.com \
  --source-arn arn:aws:s3:::ccg1-input-images


# Configurar el evento en el bucket ccg1-input-images
# Este paso es necesario para que lambda reaccione al evento ObjectCreated en S3
TG_FUNCTION_ARN=$(aws lambda get-function --function-name thumbnail-generator \
    --query 'Configuration.FunctionArn' --output text)
cat > notification.json <<EOF
{
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "${TG_FUNCTION_ARN}",
      "Events": ["s3:ObjectCreated:*"]
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
  --bucket ccg1-input-images \
  --notification-configuration file://notification.json
```

## Código

El código de este proyecto está en `src/thumbnail-generator/lambda_function.py` contiene una funcion
lambda con un header de la siguiente manera

```
def lambda_handler(event, context):
```

El siguiente comando funciona para actualizar la lambda si hemos hecho cambios al código

```
# [Alumno] ¿Notaste la versión optimizada del script de empaquetado? ¿Qué hace?

# Actualizar el código
aws lambda update-function-code \
    --function-name thumbnail-generator \
    --zip-file fileb://thumbnail-generator.zip
```

Con este comando podemos subir una imagen a S3, y hacer trigger del evento que va a llamar la lambda

```
aws s3 cp dog-01.jpg s3://ccg1-input-images/
```

Para hacer debug de la lambda podemos entrar a CloudWatch en la consola.

Dependiendo de lo que estemos haciendo, puede ser necesario subir la memoria o el timeout de la
lambda En este caso la memoria la elegimos de 512 MB y el timeout 10 segundos.

```
aws lambda update-function-configuration \
  --function-name thumbnail-generator \
  --memory-size 512 \
  --timeout 10
```

## Destruir recursos

```
# Eliminar bucket
aws s3 rm s3://ccg1-input-images --recursive
aws s3 rb s3://ccg1-input-images --region us-east-1

aws s3 rm s3://ccg1-thumbnail-images --recursive
aws s3 rb s3://ccg1-thumbnail-images --region us-east-1

# Eliminar lambda
aws lambda delete-function --function-name thumbnail-generator

# Elimina logs de CloudWatch
aws logs delete-log-group --log-group-name /aws/lambda/thumbnail-generator

```

## Notas:

- Es importante eliminar los logs de CloudWatch que acabamos de generar. En ambientes productivos la
  eliminación no se hace de forma manual, más adelante vamos a aprender más sobre CloudWatch y cómo
  configurar un retention period.
- En este demo se está usando Python 3.14, debes revisar que la lambda soporte la el runtime que
  quieres utilizar, si no es neceario cambiarlo.
