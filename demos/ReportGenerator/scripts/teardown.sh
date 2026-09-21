#!/bin/bash
set -e

REGION=us-east-1
API_NAME="ReporteVuelosAPI"
STATE_MACHINE_NAME="ReporteVuelosStateMachine"
TABLE_NAME="RegistroDespegue"
BUCKET_NAME="reporte-vuelos-demo-260921"
LAMBDA_NAMES=("validate_reporte" "buscar_vuelos" "crear_reporte" "guardar_reporte")

# API Gateway
API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='$API_NAME'].ApiId" --output text)
if [ -n "$API_ID" ]; then
    aws apigatewayv2 delete-api --api-id "$API_ID"
    echo "API Gateway $API_NAME ($API_ID) eliminado"
else
    echo "API Gateway $API_NAME no encontrado"
fi

# Step Functions
STATE_MACHINE_ARN=$(aws stepfunctions list-state-machines \
    --query "stateMachines[?name=='$STATE_MACHINE_NAME'].stateMachineArn" --output text)
if [ -n "$STATE_MACHINE_ARN" ]; then
    aws stepfunctions delete-state-machine --state-machine-arn "$STATE_MACHINE_ARN"
    echo "State Machine $STATE_MACHINE_NAME eliminada"
else
    echo "State Machine $STATE_MACHINE_NAME no encontrada"
fi

# Lambdas
for FUNC_NAME in "${LAMBDA_NAMES[@]}"; do
    if aws lambda get-function --function-name "$FUNC_NAME" >/dev/null 2>&1; then
        aws lambda delete-function --function-name "$FUNC_NAME"
        echo "Lambda $FUNC_NAME eliminada"
    else
        echo "Lambda $FUNC_NAME no encontrada"
    fi
done

# DynamoDB
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region $REGION >/dev/null 2>&1; then
    aws dynamodb delete-table --table-name "$TABLE_NAME" --region $REGION >/dev/null
    echo "Tabla $TABLE_NAME eliminada"
else
    echo "Tabla $TABLE_NAME no encontrada"
fi

# S3 (vaciar antes de borrar)
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    aws s3 rm "s3://$BUCKET_NAME" --recursive
    aws s3 rb "s3://$BUCKET_NAME"
    echo "Bucket $BUCKET_NAME eliminado"
else
    echo "Bucket $BUCKET_NAME no encontrado"
fi

echo "Teardown completo"
