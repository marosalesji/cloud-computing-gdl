#!/bin/bash
set -e

BUCKET_NAME="marosalesji-website.com"
REGION="us-east-1"

echo "Sincronizando contenido de ./public al bucket S3: $BUCKET_NAME"

aws s3 sync ./public s3://$BUCKET_NAME \
  --region $REGION

echo "Actualización completada"
echo "Sitio web:"
echo "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
