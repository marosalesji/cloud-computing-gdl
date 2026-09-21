#!/bin/bash
set -e

STATE_MACHINE_NAME="ReporteVuelosStateMachine"

LAB_ROLE_ARN=$(aws iam get-role --role-name LabRole --query 'Role.Arn' --output text)
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

DEFINITION=$(sed "s/\$AWS_ACCOUNT/$AWS_ACCOUNT/g" scripts/state_machine.json)

STATE_MACHINE_ARN=$(aws stepfunctions create-state-machine \
  --name "$STATE_MACHINE_NAME" \
  --definition "$DEFINITION" \
  --role-arn "$LAB_ROLE_ARN" \
  --type STANDARD \
  --query 'stateMachineArn' --output text)

echo "State Machine ARN: $STATE_MACHINE_ARN"

aws lambda update-function-configuration \
  --function-name validate_reporte \
  --environment "Variables={STATE_MACHINE_ARN=$STATE_MACHINE_ARN}" >/dev/null

echo "STATE_MACHINE_ARN configurado en validate_reporte"
