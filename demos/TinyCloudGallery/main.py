"""
TinyCloudGallery main module
"""

import boto3
import uvicorn
from fastapi import FastAPI
from typing import List

app = FastAPI(title="TinyCloudGallery")

s3_client = boto3.client("s3")


@app.get("/list")
def list_objects(bucket: str) -> dict:
    """List all objects in a given S3 bucket"""
    try:
        response = s3_client.list_objects_v2(Bucket=bucket)
        objects = response.get("Contents", [])
        return {
            "bucket": bucket,
            "count": len(objects),
            "objects": [{"key": obj["Key"], "size": obj["Size"]} for obj in objects]
        }
    except Exception as e:
        return {"error": str(e)}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
