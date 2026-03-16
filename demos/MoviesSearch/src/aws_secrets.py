import os
import json
import logging
import boto3
import botocore
from fastapi import HTTPException

logger = logging.getLogger(__name__)

SECRET_NAME = os.environ.get("SECRET_NAME", "videoclub/moviesearch/credentials")
AWS_REGION  = os.environ.get("AWS_REGION", "us-east-1")


def get_db_credentials() -> dict:
    client = boto3.client("secretsmanager", region_name=AWS_REGION)
    try:
        response = client.get_secret_value(SecretId=SECRET_NAME)
    except botocore.exceptions.ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "ResourceNotFoundException":
            msg = f"El secreto '{SECRET_NAME}' no existe en Secrets Manager"
        elif error_code == "AccessDeniedException":
            msg = f"Sin permisos para acceder al secreto '{SECRET_NAME}'"
        else:
            msg = f"Error al obtener credenciales: {error_code}"
        logger.error(msg)
        raise HTTPException(status_code=503, detail=msg)

    secret = json.loads(response["SecretString"])
    logger.info("Credenciales obtenidas de Secrets Manager")
    return secret
