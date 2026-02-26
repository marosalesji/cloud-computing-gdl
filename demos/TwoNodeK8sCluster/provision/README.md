# Terraform + Kubernetes (k3s)

Cluster de 2 nodos (1 controller + 1 worker) en AWS usando Terraform

## HashiCorp Cloud Platform

Pero primero vamos a configurar de forma local terraform cloud. Para esto ya debemos
tener una cuenta en HashiCorp Cloud Platform (HCP)

```
terraform login
```

Es necesario crear una organización y un workspace en HCP.

También es necesario crear Variables con las credenciales de AWS.
- aws_access_key_id
- aws_secret_access_key
- aws_session_token
- region


## Correr Terraform

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
#ssh -i k3s.pem ubuntu@$CONTROLLER_IP
#ssh -i k3s.pem ubuntu@$WORKER_IP

# 8. Obtener el kubeconfig desde el controller
mkdir ~/.kube
ssh -i k3s.pem ubuntu@$CONTROLLER_IP \
  "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# 10. Verificar el cluster dentro del controller
kubectl get nodes

# 11. Si queremos conectarnos desde nuestra laptop es necesario hacer un SSH tunnel
ssh -i k3s.pem -L 6443:127.0.0.1:6443 ubuntu@$CONTROLLER_IP
# Luego desde la laptop ya podemos correr
kubectl get nodes

# 12. Destruir toda la infraestructura cuando ya no se necesite
terraform destroy
```


### Para verificar la instalación del cluster

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

## References
- [k3s](https://k3s.io/)
