# Terraform + Kubernetes (k3s)

Cluster de 2 nodos (1 controller + 1 worker) en AWS usando Terraform

```
# 1. Inicializar Terraform
terraform init

# 2. Validar la configuración
terraform validate

# 3. Revisar el plan de ejecución
terraform plan

# 4. Crear la infraestructura
terraform apply

# 5. Extraer la llave privada generada por Terraform
#    (necesaria para SSH y debugging)
terraform output -raw ssh_private_key > k3s.pem
chmod 600 k3s.pem

# 6. Obtener las IPs públicas de las instancias
terraform output controller_public_ip
terraform output worker_public_ip

# 7. Conectarse por SSH a las instancias (opcional, para debug)
ssh -i k3s.pem ec2-user@<CONTROLLER_PUBLIC_IP>
ssh -i k3s.pem ec2-user@<WORKER_PUBLIC_IP>

# 8. Obtener el kubeconfig desde el controller
ssh -i k3s.pem ec2-user@<CONTROLLER_PUBLIC_IP> \
  "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# 9. Editar el kubeconfig local
#    Reemplazar 127.0.0.1 por la IP pública del controller
# server: https://<CONTROLLER_PUBLIC_IP>:6443

# 10. Verificar el cluster
kubectl get nodes

# 11. Destruir toda la infraestructura cuando ya no se necesite
terraform destroy
```
