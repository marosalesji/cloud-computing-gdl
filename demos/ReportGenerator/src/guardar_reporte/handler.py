import os
import boto3

BUCKET_NAME = os.environ.get("S3_BUCKET", "reporte-vuelos-demo")
s3 = boto3.client("s3")

def main(event, context):
    fecha = event.get("fecha")
    reporte = event.get("reporte", "")

    key = f"reporte_{fecha}.txt"
    s3.put_object(Bucket=BUCKET_NAME, Key=key, Body=reporte)

    return {"s3_path": f"s3://{BUCKET_NAME}/{key}"}
