#!/bin/bash
set -e

REGION=us-east-1
BUCKET_NAME="reporte-vuelos-demo"

aws s3 mb s3://$BUCKET_NAME --region $REGION

## Crear bucket S3 si no existe
#if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
#    aws s3api create-bucket \
#        --bucket "$BUCKET_NAME" \
#        --region "$REGION" \
#        --create-bucket-configuration LocationConstraint="$REGION"
#    echo "Bucket $BUCKET_NAME creado"
#else
#    echo "Bucket $BUCKET_NAME ya existe"
#fi
