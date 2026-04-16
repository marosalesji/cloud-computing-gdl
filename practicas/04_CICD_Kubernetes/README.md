# Práctica 4: CI/CD con Kubernetes

El objetivo de esta práctica es implementar un pipeline completo de CI/CD
que construya una imagen Docker, la publique en Docker Hub y la despliegue
automáticamente en un cluster de Kubernetes corriendo en AWS.

## Descripción

Vas a construir una calculadora REST desde cero. La app expone al menos
dos operaciones matemáticas como endpoints HTTP, puedes desarrollar más con el
objetivo de demostrar la funcionalidad del pipeline.

Cada operación se desarrolla en su propio branch y se integra a `main` mediante
un Pull Request.

Cuando decides publicar una versión, empujas un tag y el pipeline de CD hace el
delivery a Docker Hub y el Deployment a un cluster de Kubernetes.

## Infraestructura

Para crear el cluster de Kubernetes tienes dos opciones, puedes utilizar EKS en
AWS Learner Lab o crear un cluster de K3s usando Terraform en el sandbox de
Cloud Foundations.

Este repositorio puedes utilizarlo como base para construir el cluster:
- [k3s-platform](https://github.com/marosalesji/k3s-platform)

**Importante:** el cluster consume créditos, no olvides destruirlo.

## Pipeline CI/CD

El pipeline debe tener los siguientes tres workflows de GitHub Actions:

- **integrate** — corre en cada PR hacia `main`. Ejecuta los tests.
  El PR no se puede hacer merge si los tests fallan.
- **delivery** — corre cuando se hace push de un tag `v*` desde `main`.
  Construye la imagen y la publica en Docker Hub con el tag de versión
  y con `latest`.
- **deploy** — corre automáticamente cuando `delivery` termina con éxito.
  Aplica los manifests de Kubernetes y despliega al cluster.

Puedes usar [mini-notes](https://github.com/marosalesji/mini-notes) como
referencia para los workflows de `integrate` y `delivery`.

Observa que el workflow de `deploy` en mini-notes despliega en EC2, tú tienes
que adaptarlo para Kubernetes.

## Setup

### Cuentas necesarias

- Cuenta de Github
- Cuenta de [Docker Hub](https://hub.docker.com)
- Acceso al sandbox de AWS Academy

### Secrets en GitHub

Vas a necesitar los siguientes secrets en Github.

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `KUBECONFIG_B64`

### Protección de la rama main

Configura branch protection en GitHub para que:

- Solo se pueda integrar código a `main` mediante PR
- El workflow `integrate` debe pasar antes de mergear

## Tu tarea

A continuación agrego una lista, no exhaustiva, de lo que debes desarrollar.

1. Crea un repositorio en GitHub para tu calculadora
2. Desarrolla una REST API que exponga al menos dos operaciones, pero puedes
   necesitar más para el demo.
   Mi recomendación es que desarrolles la primera y pruebes las 3 etapas del
   pipeline, si funciona utiliza la segunda operación para demostrar en el
   video.
   Ej: suma, resta, multiplicación, división.
3. Escribe tests unitarios para cada endpoint, debes usarlo en la etapa de CI.
4. Configura los tres workflows de GitHub Actions: Continuous Integration,
   Continuous Delivery y Continuous Deployment.
5. Incluye los manifests de Kubernetes (`Deployment` y `Service`) en tu repo
6. Levantar un cluster de Kubernetes con AWS EKS o K3s con Terraform
7. Configura los secrets en GitHub
8. Debes desarrollar cada operación en su propio branch para poder crear el Pull
   Request.
   Al hacer el PR debe lanzarse automáticamente la etapa de CI.
   ```
   feat/suma → main
   feat/resta → main
   ```
9. Después de integrar una operación a main, agrega un tag siguiendo Semantic
   Versioning (major.minor.patch).
   Al recibir el tag en el branch main, se debe lanzar la etapa de Delivery y
   Deployment.
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
10. Verifica que `delivery` construya y publique la imagen en Docker Hub
11. Verifica que `deploy` despliegue al cluster
12. Confirma que los endpoints responden desde la IP pública del cluster

## Entregables

### Reporte en PDF

- Portada con nombre del alumno, nombre de la actividad, materia y fecha
- Descripción breve del pipeline: qué hace cada workflow y cuándo corre
- Respuestas a las preguntas del final
- Link al repositorio de GitHub
- Link al video

### Repositorio de GitHub

- Código de la app con tests
- Los tres workflows de GitHub Actions
- Manifests de Kubernetes
- El pipeline debe haber corrido al menos una vez con éxito para poder
  verificarlo en la pestaña Actions de GitHub

### Video (5 a 10 minutos)

El video debe mostrar:

- El cluster corriendo en EC2 o EKS
  - Mostrar la consola de AWS con las instancias de EC2 o EKS
  - Mostrar `kubectl get nodes`
- Al menos un PR con el workflow `integrate` pasando
  - Solo es necesario mostrar el PR en Github, no es necesario esperar a que
    pasen las pruebas
- El tag empujado y los workflows `delivery` y `deploy` corriendo
  - Este paso sí deben demostrarlo en video
  - Mostrar Docker Hub antes y después del delivery
  - Mostrar `kubectl get pods` antes y después del deployment
- Los endpoints respondiendo desde la IP pública del cluster

## Preguntas a responder en el reporte

1. ¿Qué problema resuelve separar `delivery` y `deploy` en dos workflows
   distintos en lugar de uno solo?

2. El kubeconfig contiene credenciales para acceder al cluster. ¿Qué
   riesgos implica guardarlo como secret en GitHub? ¿Cómo lo mitigarías
   en un entorno de producción?

3. El workflow de `deploy` de mini-notes hace SSH a EC2 y corre
   `docker run`. ¿Qué tuviste que cambiar para adaptarlo a Kubernetes
   y por qué?

4. ¿Qué secretos se agregan en Github y por qué?

5. ¿Cuál es tu conclusión de esta actividad? ¿Qué te pareció más difícil y qué
   más sencillo? Menciona 1 aprendizaje que te lleves.

## Referencias

- Referencia CI/CD: [mini-notes](https://github.com/marosalesji/mini-notes)
- Práctica guiada Kubernetes: [practicas-guiadas/kubernetes](https://github.com/marosalesji/cloud-computing-gdl/tree/main/practicas-guiadas/kubernetes)
- Infraestructura: [k3s-platform](https://github.com/marosalesji/k3s-platform)
