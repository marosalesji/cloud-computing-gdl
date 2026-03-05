import json
import os
import boto3
from datetime import datetime

STATE_MACHINE_ARN = os.environ.get("STATE_MACHINE_ARN")
sfn = boto3.client("stepfunctions")

def main(event, context):
    try:
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)

        if "fecha" not in body:
            return {"statusCode": 400, "body": json.dumps({"error": "Campo faltante: fecha"})}

        # Validar formato YYYY-MM-DD
        try:
            datetime.strptime(body["fecha"], "%Y-%m-%d")
        except ValueError:
            return {"statusCode": 400, "body": json.dumps({"error": "fecha no tiene formato YYYY-MM-DD"})}

        # Iniciar Step Function
        execution = sfn.start_execution(
            stateMachineArn=STATE_MACHINE_ARN,
            input=json.dumps(body)
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Reporte iniciado",
                "executionArn": execution["executionArn"]
            })
        }

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
