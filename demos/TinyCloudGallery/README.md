# Tiny Cloud Gallery

This is a simple cloud gallery application that allows users to upload, list, and download
images using a RESTful API. The application is built using Python and FastAPI, and it
stores images in an S3 bucket.

## run on ec2

Use `scp` to copy the code to your EC2 instance, then run the following commands:

```
scp -r . ec2-user@<ec2-public-dns>:/home/ec2-user/tiny-cloud-gallery
```

Prepare the ec2 instance with the following commands:
```
sudo yum update -y
sudo yum install python3.13
sudo yum install -y ca-certificates
sudo update-ca-trust


# copy aws credentials for the sandbox
mkdir -p ~/.aws
vi ~/.aws/credentials # copy paste here

# run the server
python3.13 -m venv venv
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
