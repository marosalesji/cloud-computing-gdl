"""
TinyCloudGallery main module
"""

import boto3
import uvicorn
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.staticfiles import StaticFiles
import os

app = FastAPI(title="TinyCloudGallery")

s3_client = boto3.client("s3")
BUCKET_NAME = "tiny-gallery"


@app.get("/list")
def list_objects() -> dict:
    """List all objects in the tiny-gallery bucket"""
    try:
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME)
        objects = response.get("Contents", [])
        return {
            "bucket": BUCKET_NAME,
            "count": len(objects),
            "objects": [{"key": obj["Key"], "size": obj["Size"]} for obj in objects]
        }
    except Exception as e:
        return {"error": str(e)}


@app.post("/upload")
async def upload_image(image_name: str = None, file: UploadFile = File(...)) -> dict:
    """Upload an image to the tiny-gallery bucket"""
    allowed_extensions = {".jpeg", ".jpg", ".png"}

    # Get file extension
    file_extension = "." + file.filename.split(".")[-1].lower() if "." in file.filename else ""

    # Validate file extension
    if file_extension not in allowed_extensions:
        return {
            "error": f"Invalid file type. Only JPEG, JPG, and PNG are allowed. Received: {file_extension if file_extension else 'no extension'}"
        }

    try:
        # Use provided image_name or fall back to original filename
        final_name = image_name if image_name else file.filename
        contents = await file.read()
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=final_name,
            Body=contents,
            ContentType=file.content_type
        )
        return {
            "message": "Image uploaded successfully",
            "filename": final_name,
            "bucket": BUCKET_NAME
        }
    except Exception as e:
        return {"error": str(e)}


@app.get("/download/{image_name}")
def download_image(image_name: str):
    """Download an image from the tiny-gallery bucket"""
    try:
        response = s3_client.get_object(Bucket=BUCKET_NAME, Key=image_name)
        return StreamingResponse(
            response["Body"].iter_chunks(chunk_size=8192),
            media_type=response.get("ContentType", "image/jpeg")
        )
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Image not found: {str(e)}")


# Serve static files - must be last
app.mount("/", StaticFiles(directory=os.path.dirname(__file__), html=True), name="static")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
