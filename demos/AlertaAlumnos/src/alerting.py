"""
AlertaAlumnos main module
"""

import os
import boto3
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles


# --------------------------------------
# Cargar .env desde src
# --------------------------------------
dotenv_path = os.path.expanduser("~/src/.env")
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)
else:
    raise RuntimeError(f"No se encontró {dotenv_path}")

# --------------------------------------
# Configuración
# --------------------------------------
TOPIC_ARN = os.getenv("TOPIC_ARN")
if not TOPIC_ARN:
    raise RuntimeError("Debes definir TOPIC_ARN en el archivo .env")

sns_client = boto3.client("sns", region_name="us-east-1")
app = FastAPI(title="AlertaAlumnos")

# --------------------------------------
# Modelos de datos
# --------------------------------------
class Alert(BaseModel):
    message: str  # Formato: tipo|mensaje|timestamp


# --------------------------------------
# Endpoints
# --------------------------------------
@app.post("/send-alert")
def send_alert(alert: Alert):
    """
    Publica un mensaje en el topic de SNS
    """
    try:
        response = sns_client.publish(
            TopicArn=TOPIC_ARN,
            Message=alert.message
        )
        return {
            "message": "Alerta enviada correctamente",
            "sns_message_id": response.get("MessageId")
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error enviando alerta: {str(e)}")


# --------------------------------------
# Main
# --------------------------------------

# Serve static files - must be last
app.mount("/", StaticFiles(directory=os.path.dirname(__file__), html=True), name="static")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
