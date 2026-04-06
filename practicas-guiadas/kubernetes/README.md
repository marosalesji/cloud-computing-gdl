# Practica guiada: kubernetes

En la práctica guiada de contenedores subiste una aplicación llamada `app1` a
Docker Hub, vamos a reusar esa aplicación para hacer un deployment en kubernetes
utilizando AWS EKS.

## Requisito: eksctl

`eksctl` es la herramienta oficial para crear y administrar clusters de EKS
desde la línea de comandos.

### macOS

```bash
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
eksctl version
```

### Windows (WSL con Ubuntu) y Linux

```bash
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
tar -xzf eksctl_Linux_amd64.tar.gz
sudo mv eksctl /usr/local/bin/
rm eksctl_Linux_amd64.tar.gz
eksctl version
```

## Crear EKS cluster en AWS

Debes tener tus credenciales de AWS Academy configuradas antes de continuar.

Crea el cluster con el siguiente comando, es normal que tarde de 10 a 20
minutos.

Primero obtén tu Account ID y edita el archivo `cluster.yaml` reemplazando
`<ACCOUNT_ID>` con ese valor en las dos líneas que lo mencionan:

```bash
aws sts get-caller-identity --query Account --output text
```

Luego crea el cluster:

```bash
eksctl create cluster -f cluster.yaml
```

Cuando termine, verifica que el cluster está listo y que `kubectl` quedó
configurado automáticamente:

```bash
kubectl get nodes
```

- ¿cuántos nodos tenemos?
- ¿tenemos control plane?

## Crear el Deployment

En este directorio encontrarás dos templates para hacer el despliegue en el
cluser de EKS: `deployment.yaml` y `service.yaml`. Completa los campos marcados
con `#` en cada uno para hacer el despliegue de 1 replica de la aplicación
`app1`.

Si no tienes tu propia imagen publicada en Docker Hub, puedes usar
`marosalesji/app1:v0.1`.

- ¿qué es un `Deployment` y un `Service` en kubernetes?
- ¿qué relación hay entre el `selector` del Deployment y el `selector` del
  Service?
- ¿qué pasa si los labels no coinciden?

Cuando los hayas completado, aplícalos:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Verifica que los pods están corriendo:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

Para ver más detalle de un pod:

```bash
kubectl describe pod <nombre-del-pod>
```

- ¿qué mensajes de error te estuvieron saliendo?
- ¿cómo los resolviste?

## Acceder a la aplicación

Con NodePort, la app queda expuesta en el puerto `30080` de cada nodo del
cluster. Los nodos EC2 tienen un firewall (Security Group) que por default
bloquea el tráfico externo — hay que abrirlo:

```bash
CLUSTER_SG=$(aws eks describe-cluster --name practica-k8s \
  --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $CLUSTER_SG \
  --protocol tcp \
  --port 30080 \
  --cidr 0.0.0.0/0
```

Ahora obtén la IP pública de uno de los nodos:

```bash
kubectl get nodes -o wide
```

Usa la columna `EXTERNAL-IP` para acceder:

```
http://<EXTERNAL-IP>:30080/tareas
```

- ¿por qué funciona aunque accedas a cualquiera de los dos nodos?

Agrega y borra tareas usando el mecanismo para enviar HTTP requests que desees
(curl, /docs de FastAPI, postman).


## Incrementar a 3 replicas

Incrementa a 3 replicas el despliegue:

```bash
kubectl scale deployment <nombre-de-tu-deployment> --replicas=3
```

Verifica que los 3 pods están corriendo:

```bash
kubectl get pods
```

Ahora agrega las siguientes tareas una por una, y después de cada una haz GET
a `/tareas` varias veces:

1. Comprar leche
2. Estudiar para el examen de kubernetes
3. Llamar al dentista
4. Hacer ejercicio
5. Leer el capítulo 3

```bash
# agregar una tarea
curl -X POST http://<EXTERNAL-IP>:30080/tareas \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Comprar leche"}'

# ver todas las tareas
curl http://<EXTERNAL-IP>:30080/tareas
```

- ¿las tareas que agregaste siempre aparecen en el GET?
- ¿en qué se diferencia esto de cuando había 1 sola réplica?
- ¿cuántos procesos de la aplicación están corriendo ahora mismo?
- ¿dónde se está guardando las tareas?
- ¿cómo lo resolverías?

## Limpiar el ambiente

Cuando termines la práctica elimina el cluster para no generar costos
innecesarios. Este comando elimina todos los recursos que se crearon: nodos EC2,
Security Groups y el control plane de EKS.

```bash
eksctl delete cluster --name practica-k8s --region us-east-1
```
