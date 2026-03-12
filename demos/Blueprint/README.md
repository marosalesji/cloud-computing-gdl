# Blueprint

En este demo vamos a construir recursos en AWS a través de Terraform, un sistema que nos ofrece
Infraestructura como Código (IaC).

## ¿Qué vamos a crear?

Con este demo provisionamos dos recursos en AWS:

- Una instancia EC2: el servidor virtual donde vivirá nuestra aplicación
- Un bucket S3: el almacenamiento de objetos donde persistiremos archivos

La idea central es que en lugar de crear estos recursos manualmente desde la consola de AWS,
o con scripts de bash, los describimos en código. Eso significa que cualquiera con acceso al
repo puede reproducir exactamente la misma infraestructura, en cualquier momento.

## Requisitos

- Terraform instalado (`terraform -v` para verificar)
- Credenciales de AWS configuradas en `~/.aws/credentials`

## Configuración

Antes de correr Terraform, crea un archivo `terraform.tfvars` en este directorio con tu número
de expediente. Esto garantiza que el nombre de tu bucket sea único en S3:

```hcl
expediente = "tu-numero-de-expediente"
```

Opcionalmente puedes sobreescribir cualquier otra variable definida en `variables.tf`:

```hcl
expediente    = "123456"
region        = "us-east-1"
instance_type = "t3.micro"
project_name  = "blueprint"
```

## Flujo de Terraform

```bash
# 1. Inicializar Terraform - descarga los providers necesarios
terraform init

# 2. Validar la configuración - verifica que el código no tenga errores de sintaxis
terraform validate

# 3. Revisar el plan de ejecución - muestra qué recursos se van a crear sin crearlos aún
terraform plan

# 4. Crear la infraestructura
terraform apply -auto-approve

# A veces es necesario correr así para asegurarnos que aplican los cambios del script
terraform apply -replace="aws_instance.server"
```

## Verificar los recursos creados
Al finalizar el `apply`, Terraform imprime los outputs definidos en `outputs.tf`:

```
server_public_ip  = "X.X.X.X"
server_instance_id = "i-XXXXXXXXXXXX"
bucket_name       = "blueprint-storage-tu-expediente"
bucket_arn        = "arn:aws:s3:::blueprint-storage-tu-expediente"
```

Puedes también consultarlos en cualquier momento con:

```bash
terraform output
```

Para extraer la llave privada de terraform y usarla para conectarte a la instancia de EC2

```
terraform output -raw private_key_pem > blueprint-key.pem
chmod 400 blueprint-key.pem

ssh -i blueprint-key.pem ubuntu@$(terraform output -raw server_public_ip)
```

## Destruir la infraestructura
Cuando termines, elimina todos los recursos para no generar costos innecesarios:

```bash
terraform destroy -auto-approve
```

## tfstate

Importante: no borres ni modifiques el archivo `terraform.tfstate`

Terraform genera este archivo automáticamente al hacer apply. Contiene el registro de todos los recursos que creó y es
lo que le permite saber qué existe en AWS y qué no. Si lo borras, Terraform pierde el rastro de tu infraestructura y no
podrá actualizarla ni destruirla correctamente, y podrías quedarte con recursos corriendo en AWS generando costos sin
poder eliminarlos fácilmente.
