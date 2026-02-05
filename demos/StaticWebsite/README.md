# Static Website

## Hugo + Git Submodules + AWS S3

Vamos a crear un sitio web estático utilizando Hugo, un generador de sitios estáticos rápido y flexible, y
almacenamiento en la nube con el servicio de Amazon S3.

Instalar Hugo

```bash
# MacOS
brew install hugo

# Ubuntu / WSL2
sudo apt update
sudo apt install hugo

# Fedora
sudo dnf update
sudo dnf install hugo

# Verificar instalación
hugo version
```

Clonar este repositorio

```bash
git clone --recurse-submodules https://github.com/marosalesji/cloud-computing-gdl.git

# Si clonaste sin el flag --recurse-submodules
cd cloud-computing-gdl
git submodule update --init --recursive

```
Ejecutar el servidor de desarrollo localmente

```bash
cd demos/StaticWebsite/mi-portafolio
hugo server -D

# Accede a http://localhost:1313
# El flag `-D` muestra posts en borrador.
```

##  Estructura del proyecto

Este proyecto usa **Git submodules** para gestionar el tema Hugo. Esto significa:

- El tema está versionado en Git
- Otros desarrolladores lo descargan automáticamente
- Puedes actualizar a nuevas versiones del tema
- Separación clara entre tu código y dependencias

Carpeta del Tema

```
mi-portafolio/themes/hugo-theme-console/  ← Git submodule
```

**NO edites archivos aquí directamente.** Para personalizar, copia archivos a `layouts/` en la raíz del proyecto.

Para crear contenido:

```bash
# Nueva entrada de blog
hugo new posts/mi-primer-post.md
vi content/posts/mi-primer-post.md

# Agregar fotos
hugo new photos/mi-galeria.md
```

### Estructura de secciones
- `content/posts/` -> Blog posts
- `content/photos/` -> Galerías de fotos
- `content/about/` -> Página sobre ti

## Configuración Inicial

Edita `hugo.toml` en la raíz de `mi-portafolio/`:

```toml
baseURL = "http://localhost:1313/"
languageCode = "es"
title = "Mi Portafolio"
theme = "hugo-theme-console"

[params]
  titleCutting = true
  animateStyle = "animated zoomIn fast"
```

## Administración de Submodules

Actualizar el tema a la última versión

```bash
cd mi-portafolio
git submodule update --remote
```

Ver el commit exacto del tema
```bash
git ls-files --stage themes/hugo-theme-console
```

## Despliegue en AWS S3

Para generar el sitio estático listo para producción:

```bash
cd mi-portafolio
hugo
```

Los archivos estáticos estarán en `public/`.

Instalar AWS CLI si no está instalado

Configurar las credenciales de AWS y sincronizar la carpeta `public` con el bucket de S3.

```
# Configurar AWS CLI
~/.aws/credentials

# Sync public folder to S3 bucket
aws s3 sync public s3://marosalesji-portafolio.com
```

## Recursos

- [Hugo Quick Start](https://gohugo.io/getting-started/quick-start/)
- [Hugo Theme Console](https://github.com/mrmierzejewski/hugo-theme-console)
- [Git Submodules Guide](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
