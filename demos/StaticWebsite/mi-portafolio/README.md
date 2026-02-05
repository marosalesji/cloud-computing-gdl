# Mi Portafolio - Hugo Static Site

Proyecto Hugo usando el tema [hugo-theme-console](https://github.com/mrmierzejewski/hugo-theme-console) para crear un portafolio personal estático.

## Estructura del Proyecto

```
mi-portafolio/
├── content/                  # Contenido del sitio
│   ├── _index.md             # Página de inicio
│   ├── posts/                # Blog posts
│   ├── photos/               # Galerías
│   └── about/                # Página acerca de
├── themes/
│   └── hugo-theme-console/   # Tema (Git submodule - NO EDITAR)
├── layouts/                  # Plantillas personalizadas
├── static/                   # Archivos estáticos (imágenes, CSS)
├── hugo.toml                 # Configuración principal
├── public/                   # Output generado (ignorar)
└── .gitignore                # Archivos a ignorar en Git
```
## Inicio Rápido

### Clonar con Submodules

```bash
git clone --recurse-submodules <repo-url>
cd mi-portafolio
hugo server -D
```
O si ya clonaste sin submodules:

```bash
git submodule update --init --recursive
hugo server -D
```

Luego abre http://localhost:1313

## Build

```bash
hugo  # Genera public/
```

## Recursos

- [Hugo Docs](https://gohugo.io/)
- [Theme Docs](https://github.com/mrmierzejewski/hugo-theme-console)
- [Markdown Guide](https://www.markdownguide.org/)
