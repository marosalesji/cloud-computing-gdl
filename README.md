# Desarrollo en la nube

Este repositorio es un recurso adicional para el curso de Desarrollo en la Nube.

## Detalles del curso

El curso está pensado para realizarse a lo largo de 30 sesiones síncronas en las que los
alumnos con la guía de un instructor revisarán conceptos, verán demostraciones y realizarán
prácticas.


| Semana | Sesión | Temas |
|--------|--------|-------|
| 1 | Sesión 1 | Bienvenida del curso. Introducción a la nube y al desarrollo en la nube. |
| 1 | Sesión 2 | **Módulo 1: Introducción al cómputo en la nube.** Computación distribuida. Arquitectura cliente-servidor. Arquitectura entre pares. Computación paralela. Modelos de servicio. |
| 2 | Sesión 3 | **Módulo 1: Introducción al cómputo en la nube.** Modelos de despliegue. Proveedores de nubes públicas. Modelos y proyecciones de costos. |
| 2 | Sesión 4 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Configuración de entorno de desarrollo. Cómputo en la nube. EC2. Actividad en clase. |
| 3 | Sesión 5 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Almacenamiento de objetos. Actividad en clase. |
| 4 | Sesión 6 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Actividad en clase: cómputo con almacenamiento de objetos. |
| 4 | Sesión 7 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Bases de datos relacionales. Bases de datos de clave-valor. Bases de datos de documentos. Actividad en clase. |
| 5 | Sesión 8 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Servicios de colas. Servicios de notificaciones. Servicios de flujos de datos. Actividad en clase. Formación de equipos para el proyecto integrador. |
| 5 | Sesión 9 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Despliegue y automatización con scripts. Práctica en clase. |
| 6 | Sesión 10 | **Módulo 2: Servicios que apoyan al desarrollo en la nube.** Gestión de usuarios y secretos. |
| 6 | Sesión 11 | **Módulo 3: Serverless y FaaS.** Concepto de Serverless. Function as a Service. |
| 7 | Sesión 12 | **Módulo 3: Serverless y FaaS.** Implementación de APIs con servicios serverless. |
| 7 | Sesión 13 | **Módulo 3: Serverless y FaaS.** Actividad en clase. Resolución de dudas. |
| 8 | Sesión 14 | Evaluación: parte práctica y parte teórica. |
| 8 | Sesión 15 | **Módulo 4: Infraestructura como código.** Qué es infraestructura como código. Terraform. |
| 9 | Sesión 16 | Primera revisión del proyecto integrador. **Módulo 4: Contenedores y orquestación.** Concepto de contenedores e imágenes. |
| 10 | Sesión 17 | **Módulo 4: Contenedores y orquestación.** Ciclo de vida de un contenedor. Demo. Actividad en clase. |
| 10 | Sesión 18 | **Módulo 4: Contenedores y orquestación.** Orquestación de contenedores. Kubernetes. Demo. |
| 11 | Sesión 19 | **Módulo 4: Contenedores y orquestación.** Kubernetes. Práctica en clase. Conversación con profesional de la industria.|
| 11 | Sesión 20 | **Módulo 5: Metodología de las aplicaciones de 12 factores.** Razón de la metodología. Los 12 factores. |
| 12 | Sesión 21 | **Módulo 5: Metodología de las aplicaciones de 12 factores.** Los 12 factores. Implementación en flujos de CI/CD. |
| 12 | Sesión 22 | Segunda revisión del proyecto integrador. **Módulo 5: Metodología de las aplicaciones de 12 factores.** Actividad en clase. |
| 13 | Sesión 23 | **Módulo 6: Monitoreo de aplicaciones.** Cultura de DevOps. |
| 13 | Sesión 24 | **Módulo 6: Monitoreo de aplicaciones.** Métricas. Alarmas y alertas. Paneles y dashboards. |
| 14 | Sesión 25 | **Módulo 7: Arquitecturas de desarrollo en la nube.** Monolitos. Microservicios. |
| 14 | Sesión 26 | **Módulo 7: Arquitecturas de desarrollo en la nube.** Tradeoff. |
| 15 | Sesión 27 | Evaluación: parte práctica y parte teórica. |
| 15 | Sesión 28 | Actividad práctica. |
| 16 | Sesión 29 | Entrega final y defensa del proyecto integrador. |
| 16 | Sesión 30 | Entrega final y defensa del proyecto integrador. |

## Demos

Actividades guiadas para aprender y utilizar servicios de AWS.

### Servicios de AWS

|Tema|Descripción|Ejercicio|
|---|---|---|
|S3|Un sitio web estatico|[StaticWebsite](demos/StaticWebsite)|
|EC2 + S3|Galeria de imagenes|[TinyCloudGallery](demos/TinyCloudGallery)|
|RDS|Administra una base de datos de peliculas con RDS y postgres|[MoviesCatalog](demos/MoviesCatalog)|
|DynamoDB|Una tienda de abarrotes administra sus productos en DynamoDB|[ProductCatalog](demos/ProductCatalog)|
|SQS|Una cafeteria usa SQS para administrar las horas pico|[Cafeteria](demos/Cafeteria/)|
|SNS|AlertaAlumnos es un sistema que utiliza SNS para enviar notificaciones|[AlertaAlumnos](demos/AlertaAlumnos/)|
|Lambda|Crear thumbnails con una lambda|[ThumbnailGenerator](demos/ThumbnailGenerator)|
|Lambda + Step Functions + API Gateway + DynamoDB|Aplicacion que genera reportes de vuelos que despegaron|[ReportGenerator](demos/ReportGenerator)|

### Contenedores y orquestadores

Actividades guiadas para aprender sobre contenedores y orquestadores.

|Tema|Descripción|Ejercicio|
|---|---|---|
||Provision de un EC2 y S3|[Blueprint](demos/Blueprint)|
|Docker|||
|Kubernetes||


## Retos

Algunos retos para los alumnos.
