#!/bin/bash
set -e

LAB_ROLE_ARN=$(aws iam get-role --role-name LabRole --query 'Role.Arn' --output text)
RUNTIME="python3.14"
HANDLER="handler.main"

# Empaquetar cada Lambda en src y crear o actualizar
for dir in src/*; do
    [ -d "$dir" ] || continue
    FUNC_NAME=$(basename "$dir")
    ZIP_FILE="$FUNC_NAME.zip"

    # Crear zip
    cd "$dir"
    zip -r "../../$ZIP_FILE" ./*
    cd - >/dev/null

    if aws lambda get-function --function-name "$FUNC_NAME" >/dev/null 2>&1; then
        echo "Actualizando Lambda existente: $FUNC_NAME"
        aws lambda update-function-code \
            --function-name "$FUNC_NAME" \
            --zip-file "fileb://$ZIP_FILE"
    else
        echo "Creando Lambda: $FUNC_NAME"
        aws lambda create-function \
            --function-name "$FUNC_NAME" \
            --runtime "$RUNTIME" \
            --role "$LAB_ROLE_ARN" \
            --handler "$HANDLER" \
            --zip-file "fileb://$ZIP_FILE" \
            --timeout 900 \
            --memory-size 1024
    fi
done


# Incrementar memoria en lambda
aws lambda update-function-configuration \
    --function-name buscar_vuelos \
    --memory-size 2048
