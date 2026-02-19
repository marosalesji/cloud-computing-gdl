#!/bin/bash
set -e

# Leer el ARN del topic desde el archivo oculto
if [ ! -f ".env" ]; then
  echo "No se encontró el archivo .env con TOPIC_ARN"
  exit 1
fi

source .env

if [ -z "$TOPIC_ARN" ]; then
  echo "TOPIC_ARN no está definido en .env"
  exit 1
fi

# Leer mensaje de los parámetros del usuario
if [ $# -eq 0 ]; then
  echo "Uso: $0 'tipo|mensaje'"
  exit 1
fi

INPUT_MSG="$1"

# Append timestamp to create final message: type|message|timestamp
USER_MSG="$INPUT_MSG|$(date '+%Y-%m-%d %H:%M:%S')"

echo "Publicando mensaje a SNS: $USER_MSG"

aws sns publish \
  --topic-arn "$TOPIC_ARN" \
  --message "$USER_MSG" \
  --region us-east-1

echo "Mensaje publicado"
