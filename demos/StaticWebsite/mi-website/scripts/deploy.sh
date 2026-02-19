#!/bin/bash
set -e
set -x

BUCKET_NAME="marosalesji-website.com"
REGION="us-east-1"


aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \

aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
  BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

aws s3api put-bucket-website \
  --bucket $BUCKET_NAME \
  --website-configuration '{
    "IndexDocument": { "Suffix": "index.html" },
    "ErrorDocument": { "Key": "404.html" }
  }'

aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Principal\": \"*\",
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\"
    }]
  }"


echo "Subiendo archivos al bucket S3..."

aws s3 sync public/ s3://$BUCKET_NAME \
  --region $REGION \
  --delete

echo "Deploy completado"
echo ""
echo "Sitio web:"
echo "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
