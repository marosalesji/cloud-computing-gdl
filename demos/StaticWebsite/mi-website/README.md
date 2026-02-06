# mi-website

Para esta actividad realiza los siguientes pasos

## Parte 1

La primera parte de esta actividad corresponde al tutoria "Tutorial: Configuring a static website on Amazon S3" [1]
con algunas variantes. El objetivo es entender cómo crear un bucket con el servicio de S3 y configurarlo para
alojar sitios web estáticos.

### 1. Crea un bucket con la configuración default

Entra a la consola de AWS en el sandbox de AWS Academy.

Para entrar al servicio de S3 puedes escribir "S3" en la barra de búsqueda de arriba, y dar doble click en el servicio.

Dentro del servicio de S3, en el menú de la izquieda da click en Buckets de uso general, luego da click en Crear bucket.

Dale un nombre que tú quieras, en mi caso `marosalesji-website.com`

Esta instrucción corresponde al paso 1 del tutorial de AWS.

### 2. Configuralo para alojar tu sitio web

En este caso debes seguir los pasos 2 a 4 del tutoria [1].

- habilitar `Alojamiento de sitios web estáticos`
- deshabilitar los bloqueos en `Bloquear acceso público`
- agregar una política a `Política de bucket`

*Nota: en la política del bucket vas a necesitar modificar el nombre del bucket de la plantilla del tutorial*

### 3. Haz un sitio web estático sencillo

En este proyecto dentro del direcotrio `public` se encuentra un archivo `index.html` que puedes usar como base.

También puedes pedirle a ChatGPT que te genere uno a tu gusto.

### 4. Carga el index.html

En tu consola de AWS, donde creaste el bucket, da doble click al bucket.

Debes ver que la sección de Objetos está vacía.

Arrastra el archivo index.html a esta sección, y da click en "cargar".

### 5. Visualiza tu página web

Ahora en el bucket vas a ver el archivo que subiste, entra al archivo dando doble click.

En la sección de Propiedades vas a ver el URL del objeto, es algo así `https://s3.<region>.amazonaws.com/<bucket-name>/index.html`]

Por ejemplo `https://s3.us-east-1.amazonaws.com/marcela-website.com/index.html`

Copialo y pégalo en tu navegador, y vas a ver la página web estática.

## Parte 2

Recordemos que hay 3 formas de interactuar con los servicios de AWS
- AWS Management console: en el sitio web por medio de una interfaz gráfica
- AWS CLI: desde la terminal con línea de comandos
- Software Development Kit (SDK): programáticamente con un lenguaje de programación que sea soportado

En la parte 1 de esta actividad creamos el sitio web estático con la consola, para esta parte 2 vamos a actualizar
esa página web utilizando el CLI.

### 1. Instala el AWS CLI

Puedes buscar en Google "install aws cli wsl" si estás usando el entorno WSL, o Mac o la distribución de Linux que uses (ej. Ubuntu).

Estos son los pasos para WSL:

```bash
# Instalar paquetes con apt
sudo apt update
sudo apt install -y unzip curl

# Utiliza curl para descargar el zip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Descomprime awscli2.zip con la utileria unzip
unzip awscliv2.zip

# Instala el aws cli
sudo ./aws/install

# Si instalaste correctamente aws cli el siguiente comando debe reconocerlo
# Si sale un error que dice que no encontró el comando, significa que hubo un error
aws --version

# Eliminar los archivos que ya no son necesarios (awscli2.zip y el directorio aws)
rm -rf awscliv2.zip aws
```

*Nota: para cada entorno de desarrollo estos comandos pueden cambiar*

### 2. Configura ls credenciales de AWS CLI

Desde la página web donde lanzamos el sandbox de AWS academy, hay que dar click al botón de Details (arriba a la derecha),
luego Show. Se va a abrir una ventana donde hay que dar click en Show para ver lo siguientes

```
Cloud Access

   AWS CLI:
   Copy and paste the following into ~/.aws/credentials
```

Vamos a copiar las credenciales que ahí aparecen, para cada entorno van a cambiar.

```
[default]
aws_access_key_id=**************
aws_secret_access_key=**********
aws_session_token=**************
```

Vamos a la terminal de nuestro entorno de desarrollo y abrimos `~/.aws/credentials`, ahí vamos a pegar las credenciales.

Acá vemos dos opciones para editar el archivo desde la terminal.

```
# Utilizando nano
nano ~/.aws/credentials

# Utilizando vim
vim ~/.aws/credentials
```

También podemos usar otro editor de texto.

### 3. Listar nuestro bucket

Ahora que tenemos configuradas las credenciales de nuestro entorno remoto (el sandbox) en nuestro entorno de desarrollo (la terminal),
podemos ejecutar el siguiente comando y deberemos ver el bucket que creamos en la parte 1. En mi caso se ve así

```
aws s3 ls
2026-02-05 17:01:44 marosalesji-website.com
```

### 4. Edita el index.html

Realiza un cambio en index.html, el que quieras, el objetivo es reconocer que se actualizó el archivo en el siguiente paso.

Ejemplo:
```
  <p>Agregamos un cambio visible<p>
```

### 5. Sincroniza el archivo con AWS CLI

Utiliza el comando sync para sincronizar un directorio en tu entorno local a tu bucket de S3, es decir hacer una carga de archivos.

```
aws s3 sync ./public s3://marosalesji-portafolio.com
```

El comando s3 sync sube directorios enteros, así que cualquier cosa que esté en `public/` se subirá al bucket.

### 6. Visualiza el cambio

Refresca la página en tu navegador con tu sitio web estático, debes ver el cambio que agregaste a `index.html`.


## Siguientes pasos

- Puedes investigar qué otros comandos, subcomandos y parámetros tiene el AWS CLI `aws`.
- Puedes construir tu propio sitio web más complicado y subir su contenido (ej lo que está dentro de public)
- Puedes intentar hacer el proyecto `mi-portafolio` utilizando de este demo.


# Referencias
- [1] [Tutorial: Configuring a static website on Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html)
