#!/bin/bash
set -e

# Leer el ARN del topic desde el archivo .env
if [ ! -f ".env" ]; then
  echo "No se encontró el archivo .env con TOPIC_ARN"
  exit 1
fi

source .env

if [ -z "$TOPIC_ARN" ]; then
  echo "TOPIC_ARN no está definido en .env"
  exit 1
fi

# Leer email de los parámetros del usuario
if [ $# -eq 0 ]; then
  echo "Uso: $0 'email@example.com'"
  exit 1
fi

EMAIL="$1"

echo "Suscribiendo $EMAIL al topic: $TOPIC_ARN"

aws sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "$EMAIL" \
  --region us-east-1

echo "Suscripción enviada a $EMAIL"

echo "Listar las suscripciones actuales"
aws sns list-subscriptions-by-topic --topic-arn $TOPIC_ARN
