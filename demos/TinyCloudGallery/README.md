# Tiny Cloud Gallery

This is a simple cloud gallery application that allows users to upload, list, and download
images using a RESTful API. The application is built using Python and FastAPI, and it
stores images in an S3 bucket.

## run the server

```
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

## curl the endpoints

```
 curl -X POST -F "file=@/path/to/pic01.jpeg" http://localhost:8080/upload
 curl "http://localhost:8080/list"
 curl "http://localhost:8080/download/pic01.jpeg" -o downloaded.jpg
```
