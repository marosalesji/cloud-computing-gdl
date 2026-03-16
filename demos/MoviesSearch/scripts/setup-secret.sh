#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

echo "Creando secret en Secrets Manager..."
aws secretsmanager create-secret \
  --name "videoclub/moviesearch/credentials" \
  --secret-string "{\"host\":\"$RDSHOST\",\"port\":5432,\"dbname\":\"$RDSDB\",\"username\":\"$RDSUSER\",\"password\":\"$RDSPASS\"}" \
  --region us-east-1

echo "Secret creado correctamente."
echo ""
echo "Puedes verificarlo con:"
echo "aws secretsmanager get-secret-value --secret-id videoclub/moviesearch/credentials --query SecretString --output text"
