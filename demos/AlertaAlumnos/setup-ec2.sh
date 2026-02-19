#!/bin/bash
set -ex

if [ ! -f ".env" ]; then
  echo "No se encontró el archivo .env con EC2_IP"
  exit 1
fi

source .env

if [ -z "$EC2_IP" ]; then
  echo "EC2_IP no está definido en .env"
  exit 1
fi

if [ -z "$KEY_FILE" ]; then
  echo "KEY_FILE no está definido en .env"
  exit 1
fi

SRC_DIR="src"

echo "Copiando carpeta $SRC_DIR a EC2 $EC2_IP..."
scp -i "$KEY_FILE" -r "$SRC_DIR" ec2-user@"$EC2_IP":~/src

echo "Conectando a EC2 $EC2_IP y preparando entorno Python..."

ssh -t -i "$KEY_FILE" ec2-user@"$EC2_IP" << EOF
set -euo pipefail

echo "Actualizando sistema..."
sudo yum update -y

echo "Instalando Python 3.13 y certificados..."
sudo yum install -y python3.13 ca-certificates
sudo update-ca-trust

echo "Preparando venv..."
python3 -m venv ~/venv
source ~/venv/bin/activate
source ~/src/.env

echo "Instalando dependencias desde requirements.txt..."
pip install --upgrade pip
pip install -r ~/src/requirements.txt

echo "Iniciando servidor FastAPI en background..."
# nohup + & para que siga corriendo aunque termine la sesión SSH
nohup uvicorn src.alerting:app --host 0.0.0.0 --port 8080 > uvicorn.log 2>&1 &

echo "Setup completo. Servidor corriendo en background (puerto 8080)."
EOF

echo "Setup remoto completado en EC2 $EC2_IP"
echo "Puedes conectarte con:"
echo "ssh -i $KEY_FILE ec2-user@$EC2_IP"
