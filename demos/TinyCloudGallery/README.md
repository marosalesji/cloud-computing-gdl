# Tiny Cloud Gallery

Esta aplicación es un proyecto de una galería de imágenes en la nube.
Permite subir imágenes, listarlas y descargarlas a través de una API RESTful.
La aplicación está construida utilizando Python y FastAPI, y almacena las
imágenes en un bucket de S3.

## Crear recursos EC2 y S3

El primer paso es crear una instancia EC2 y un bucket de S3 en AWS. Puedes utilizar
la consola de AWS o la CLI para crear estos recursos.

### Crear recursos utilizando la CLI de AWS

Crear bucket de S3
```
aws s3 mb s3://tiny-gallery --region us-east-1
```

Crear instancia de EC2
```
export AWS_PAGER=cat

# Crear key pair
aws ec2 create-key-pair --key-name demo-tcg-key --query 'KeyMaterial' --output text --region us-east-1 > demo-tcg-key.pem
chmod 400 demo-tcg-key.pem

# Crear grupos de seguridad
aws ec2 create-security-group --group-name demo-tcg-sg --description "Security group para Tiny Cloud Gallery" --region us-east-1
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 22 --cidr 0.0.0.0/0 --region us-east-1
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 8080 --cidr 0.0.0.0/0 --region us-east-1

aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[].IpPermissions'

# Crear una instancia EC2
# El ID del AMI lo puedes obtener en la consola de AWS.
aws ec2 run-instances \
    --image-id ami-0532be01f26a3de55 \
    --count 1 \
    --instance-type t3.micro \
    --key-name demo-tcg-key \
    --security-groups demo-tcg-sg \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=tiny-cloud-gallery}]'

# Ver IP pública de la instancia EC2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=tiny-cloud-gallery" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text \
  --region us-east-1
```

## Copia el codigo a la instancia EC2 y ejecuta la aplicación

Para este paso vamos a utilizar dos terminales, en una vamos a conectarnos a la
instancia EC2 utilizando SSH, y en la otra vamos a copiar el código utilizando SCP.

```
# Terminal 1 - Conexión SSH a la instancia EC2
ssh -i demo-tcg-key.pem ec2-user@<ec2-ip>

# Dentro de la instancia EC2
export TERM=xterm-256color
```

Una forma de correr esta aplicación es utilizando una instancia EC2, para esto
podemos utilizar el comando `scp` para copiar el código desde nuestra computadora
local a la instancia remota.

SCP (Secure Copy Protocol) es una herramienta de línea de comandos que permite
transferir archivos de entre un host local y un host remoto o entre dos hosts remotos.
Utiliza SSH para la autenticación y la transferencia de datos.

```
# Terminal 2 - Copiar código utilizando SCP
scp -i demo-tcg-key.pem -r src ec2-user@<ec2-ip>:/home/ec2-user
```

Regresa a la terminal 1 para instalar las dependencias y ejecutar la aplicación.

```
cd src
sudo yum update -y
sudo yum install -y python3.13
sudo yum install -y ca-certificates
sudo update-ca-trust

# copy aws credentials for the sandbox
mkdir -p ~/.aws
vi ~/.aws/credentials # copy paste here

# run the server
python3.13 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

```

Ya tienes el servidor corriendo en la instancia EC2, ahora puedes realizar peticiones a la API RESTful de la aplicación utilizando `curl` o cualquier cliente HTTP.

## Prueba la aplicación

En tu navegador puedes ir a <ec2-ip>:8080/docs para ver la documentación de la API generada automáticamente
por FastAPI, y probar las diferentes rutas para subir, listar y descargar imágenes.

También puedes probar la interfaz de usuario en <ec2-ip>:8080, donde puedes subir imágenes y ver la galería.

Puedes utilizar `curl` para realizar peticiones a la API RESTful de la aplicación.

```
 curl -X POST -F "file=@/path/to/pic01.jpeg" http://<ec2-ip>:8080/upload
 curl "http://<ec2-ip>:8080/list"
 curl "http://<ec2-ip>:8080/download/pic01.jpeg" -o downloaded.jpg
```

## Eliminar recursos

Una vez que hayas terminado de probar la aplicación, es importante eliminar los recursos que has creado para evitar cargos innecesarios en tu cuenta de AWS.

```
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=tiny-cloud-gallery" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text \
  --region us-east-1)

aws ec2 terminate-instances \
  --instance-ids $INSTANCE_ID \
  --region us-east-1

aws s3 rm s3://tiny-gallery --recursive
aws s3 rb s3://tiny-gallery --region us-east-1

SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=demo-tcg-sg" \
  --query 'SecurityGroups[].GroupId' \
  --output text \
  --region us-east-1)

aws ec2 delete-security-group \
  --group-id $SG_ID \
  --region us-east-1

aws ec2 delete-key-pair \
  --key-name demo-tcg-key \
  --region us-east-1

rm demo-tcg-key.pem
```

# Extra Tips

Un error común al darle nombre a un bucket es que no sea único. Es buena idea
revisar las recomendaciones para nombrar el bucket https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
