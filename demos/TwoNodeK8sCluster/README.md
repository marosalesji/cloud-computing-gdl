# Terraform + Kubernetes (k3s)

Cluster de 2 nodos (1 controller + 1 worker) en AWS usando Terraform

Pero primero vamos a configurar de forma local terraform cloud. Para esto ya debemos
tener una cuenta en HashiCorp Cloud Platform (HCP)

```
terraform login

```



```
# 1. Inicializar Terraform
terraform init

# 2. Validar la configuración
terraform validate

# 3. Revisar el plan de ejecución
terraform plan

# 4. Crear la infraestructura
terraform apply -auto-approve


# A veces es necesario correr asi para asegurarnos que aplican los cambios del script
terraform apply -replace="aws_instance.controller" -replace="aws_instance.worker"

# 5. Extraer la llave privada generada por Terraform
#    (necesaria para SSH y debugging)
terraform output -raw ssh_private_key > k3s.pem
chmod 600 k3s.pem

# 6. Obtener las IPs públicas de las instancias
CONTROLLER_IP=$(terraform output controller_public_ip | sed 's/"//g')
WORKER_IP=$(terraform output worker_public_ip | sed 's/"//g')

# 7. Conectarse por SSH a las instancias (opcional, para debug)
ssh -i k3s.pem ubuntu@$CONTROLLER_IP
ssh -i k3s.pem ubuntu@$WORKER_IP

# 8. Obtener el kubeconfig desde el controller
ssh -i k3s.pem ubuntu@$CONTROLLER_IP \
  "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# 9. Editar el kubeconfig local
#    Reemplazar 127.0.0.1 por la IP pública del controller
# server: https://$CONTROLLER_IP:6443

# 10. Verificar el cluster
kubectl get nodes

# 11. Destruir toda la infraestructura cuando ya no se necesite
terraform destroy
```


Verify k3s installation

```
# Controller
sudo systemctl status k3s.service
sudo ss -lntp | grep 6443

sudo kubectl get nodes
sudo k3s kubectl get nodes
sudo kubectl get nodes -o wide

# Worker
sudo systemctl status k3s-agent --no-pager
sudo journalctl -u k3s-agent -n 50 --no-pager


```
