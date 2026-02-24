#!/bin/bash
set -eofx

echo "==== Iniciando user-data para Ubuntu ===="

# --- SELinux (Ubuntu normalmente NO lo tiene) ---
if command -v sestatus >/dev/null 2>&1; then
  echo "SELinux detectado. Desactivándolo..."
  sudo setenforce 0 || true
  sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config || true
else
  echo "SELinux no está presente (normal en Ubuntu)"
fi

# --- Desactivar AppArmor (recomendado para K3s en Ubuntu) ---
echo "Desactivando AppArmor..."
sudo systemctl stop apparmor || true
sudo systemctl disable apparmor || true

# --- Actualizar sistema ---
echo "Actualizando paquetes (apt)..."
sudo apt-get update -y
sudo apt-get upgrade -y

# --- Dependencias básicas ---
echo "Instalando dependencias..."
sudo apt-get install -y curl ca-certificates gnupg lsb-release

# --- Obtener IP pública (EC2) ---
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "[DEBUG] public ip $PUBLIC_IP"
echo "[DEBUG] private ip $PRIVATE_IP"

# --- Instalar K3s Controller ---
echo "Instalando K3s Controller..."
curl -sfL https://get.k3s.io | \
#INSTALL_K3S_EXEC="server --token ${k3s_token} --tls-san $PUBLIC_IP" \
INSTALL_K3S_EXEC="server --token ${k3s_token} --tls-san $PRIVATE_IP" \
bash

# --- Verificación ---
echo "K3s Controller instalado"
sleep 5
sudo systemctl status k3s --no-pager || true
