#!/bin/bash
set -e

echo "Esperando a que yum se libere..."
while sudo yum lock | grep -q "another app"; do
  sleep 2
done

echo "Desactivando SELinux..."
sudo setenforce 0 || true
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config || true

echo "Instalando K3s Worker..."
curl -sfL https://get.k3s.io | \
K3S_URL="https://${controller_ip}:6443" \
K3S_TOKEN="${k3s_token}" \
INSTALL_K3S_SKIP_SELINUX_RPM=true \
sh -

echo "K3s Worker instalado exitosamente"
