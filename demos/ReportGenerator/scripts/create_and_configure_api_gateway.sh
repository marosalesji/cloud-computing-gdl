#!/bin/bash
set -e

LAMBDA_NAME="validate_reporte"
API_NAME="ReporteVuelosAPI"
RESOURCE_PATH="/reporte"

REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Crear HTTP API
API_ID=$(aws apigatewayv2 create-api \
  --name "$API_NAME" \
  --protocol-type HTTP \
  --query 'ApiId' --output text)

# Crear integración Lambda Proxy
LAMBDA_ARN="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_NAME"
INTEGRATION_ID=$(aws apigatewayv2 create-integration \
  --api-id "$API_ID" \
  --integration-type AWS_PROXY \
  --integration-uri "$LAMBDA_ARN" \
  --payload-format-version 2.0 \
  --query 'IntegrationId' --output text)

# Crear ruta POST /reporte
aws apigatewayv2 create-route \
  --api-id "$API_ID" \
  --route-key "POST $RESOURCE_PATH" \
  --target "integrations/$INTEGRATION_ID"

# Permitir que API Gateway invoque la Lambda
SOURCE_ARN="arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST$RESOURCE_PATH"
aws lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --statement-id "apigateway-invoke" \
  --action "lambda:InvokeFunction" \
  --principal apigateway.amazonaws.com \
  --source-arn "$SOURCE_ARN"

# Deploy creando el stage prod automáticamente
aws apigatewayv2 create-stage \
  --api-id "$API_ID" \
  --stage-name demo \
  --auto-deploy
