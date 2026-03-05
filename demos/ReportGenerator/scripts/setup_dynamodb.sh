#!/bin/bash
set -e

REGION=us-east-1
TABLE_NAME="RegistroDespegue"
DATA_FILE="data/flights.json"
GSI_NAME="FechaIndex"

# Crear tabla DynamoDB
aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions \
        AttributeName=flight_id,AttributeType=S \
        AttributeName=fecha_salida,AttributeType=S \
    --key-schema AttributeName=flight_id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --global-secondary-indexes "[
        {
            \"IndexName\": \"$GSI_NAME\",
            \"KeySchema\": [{\"AttributeName\":\"fecha_salida\",\"KeyType\":\"HASH\"}],
            \"Projection\": {\"ProjectionType\":\"ALL\"},
            \"ProvisionedThroughput\": {\"ReadCapacityUnits\":5,\"WriteCapacityUnits\":5}
        }
    ]" \
    --region $REGION

echo "Tabla $TABLE_NAME creada con GSI $GSI_NAME"

# Esperar a que la tabla esté activa
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

# Cargar datos iniciales
aws dynamodb batch-write-item --request-items file://scripts/batch-write-flights.json

echo "Datos precargados en $TABLE_NAME"

# Verificar tabla
aws dynamodb scan --table-name "$TABLE_NAME" --region $REGION
echo "End"

# aws dynamodb delete-table --table-name RegistroDespegue --region us-east-1
