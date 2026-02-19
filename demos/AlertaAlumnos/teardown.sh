#!/bin/bash


if [ ! -f ".env" ]; then
  echo "No se encontró el archivo .env con EC2_IP"
  exit 1
fi

source .env

if [ -z "$EC2_IP" ]; then
  echo "EC2_IP no está definido en .env"
  exit 1
fi

if [ -z "$KEY_FILE" ]; then
  echo "KEY_FILE no está definido en .env"
  exit 1
fi

if [ -z "$SECURITY_GROUP_ID" ]; then
  echo "SECURITY_GROUP_ID no está definido en .env"
  exit 1
fi

# Terminar EC2
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1

aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

# Eliminar Security Group
aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --region us-east-1

# Eliminar key pair
aws ec2 delete-key-pair --key-name alerta-alumnos-key --region us-east-1
rm alerta-alumnos-key.pem

# Eliminar SNS topic
aws sns delete-topic --topic-arn $TOPIC_ARN --region us-east-1
