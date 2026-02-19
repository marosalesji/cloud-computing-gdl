#!/bin/bash
set -e

BUCKET_NAME="marosalesji-website.com"
REGION="us-east-1"

echo "Eliminando contenido del bucket S3: $BUCKET_NAME"

# Elimina todos los objetos (incluye index.html, 404.html)
aws s3 rm s3://$BUCKET_NAME --recursive --region $REGION

echo "Eliminando bucket: $BUCKET_NAME"
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION

echo "Recursos eliminados"
