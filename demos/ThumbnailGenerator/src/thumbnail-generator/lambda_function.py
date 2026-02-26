import boto3
from PIL import Image
import io
import os

s3 = boto3.client('s3')
THUMB_BUCKET = 'ccg1-thumbnail-images'
THUMB_SIZE = (128, 128)  # tamaño del thumbnail

def lambda_handler(event, context):

    print(f"Evento: {event}")
    # Obtener info del objeto subido
    for record in event['Records']:
        print(f"Record: {record}")
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Descargar la imagen
        response = s3.get_object(Bucket=bucket, Key=key)
        img_data = response['Body'].read()
        img = Image.open(io.BytesIO(img_data))
        print(f"Imagen descargada de S3")

        # Crear thumbnail
        img.thumbnail(THUMB_SIZE)
        buffer = io.BytesIO()
        img.save(buffer, img.format)
        buffer.seek(0)

        thumbnail_filename = f"thumbnail-{key}"

        print(f"Generar thumbnail")
        print(f"Subir a bucket {THUMB_BUCKET}")
        # Subir al bucket de thumbnails
        s3.put_object(Bucket=THUMB_BUCKET, Key=thumbnail_filename, Body=buffer)
        print(f"Imagen guardada en {THUMB_BUCKET}")

    return {'status': 'ok'}
