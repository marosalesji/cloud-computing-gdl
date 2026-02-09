# Tiny Cloud Gallery

Esta aplicación es un proyecto de una galería de imágenes en la nube.
Permite subir imágenes, listarlas y descargarlas a través de una API RESTful.
La aplicación está construida utilizando Python y FastAPI, y almacena las
imágenes en un bucket de S3.

## Correr en EC2

Una forma de correr esta aplicación es utilizando una instancia EC2, para esto
podemos utilizar el comando `scp` para copiar el código desde nuestra computadora
local a la instancia remota.

SCP (Secure Copy Protocol) es una herramienta de línea de comandos que permite
transferir archivos de entre un host local y un host remoto o entre dos hosts remotos.
Utiliza SSH para la autenticación y la transferencia de datos.

```
scp -i /ruta/llave_privada -r . ec2-user@<ec2-ip>:/home/ec2-user/tiny-cloud-gallery
```

Después utiliza ssh para conectarte a la instancia EC2, e instala las dependencias
dentro de la instancia EC2.

```
sudo yum update -y
sudo yum install python3.13
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

## Realiza peticiones a la API

Puedes utilizar `curl` para realizar peticiones a la API RESTful de la aplicación.

```
 curl -X POST -F "file=@/path/to/pic01.jpeg" http://localhost:8080/upload
 curl "http://localhost:8080/list"
 curl "http://localhost:8080/download/pic01.jpeg" -o downloaded.jpg
```
