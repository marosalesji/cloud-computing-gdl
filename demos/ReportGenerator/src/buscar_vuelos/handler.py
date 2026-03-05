import os
import boto3

TABLE_NAME = os.environ.get("DYNAMO_TABLE", "RegistroDespegue")
GSI_NAME = "FechaIndex"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def main(event, context):
    fecha_req = event.get("fecha")
    if not fecha_req:
        return {"statusCode": 400, "body": "Falta el campo 'fecha'"}

    # Consultar vuelos en la fecha solicitada usando el GSI
    response = table.query(
        IndexName=GSI_NAME,
        KeyConditionExpression=boto3.dynamodb.conditions.Key("fecha_salida").eq(fecha_req)
    )
    print(f"RESULTADOS QUERY: {response}")


    vuelos_en_fecha = response.get("Items", [])

    return {"fecha": fecha_req, "vuelos": vuelos_en_fecha}
