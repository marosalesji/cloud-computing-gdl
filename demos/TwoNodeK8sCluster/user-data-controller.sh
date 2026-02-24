#!/bin/bash
set -e

echo "Esperando a que yum se libere..."
while sudo yum lock | grep -q "another app"; do
  sleep 2
done

echo "Desactivando SELinux..."
sudo setenforce 0 || true
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config || true

echo "Instalando K3s Controller..."
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="server --token ${k3s_token} --tls-san $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" \
INSTALL_K3S_SKIP_SELINUX_RPM=true \
sh -

echo "K3s Controller instalado exitosamente"
