#!/bin/bash
set -xeuo pipefail


# Nombre del topic
TOPIC_NAME="alerta-clases"
TOPIC_ARN=$(aws sns create-topic \
  --name $TOPIC_NAME \
  --query 'TopicArn' \
  --output text)
echo "SNS Topic creado: $TOPIC_ARN"

KEY_NAME="alerta-alumnos-key"
aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text \
  --region us-east-1 > "${KEY_NAME}.pem"
chmod 400 "${KEY_NAME}.pem"
echo "Key pair creada: ${KEY_NAME}.pem"

SG_ID=$(aws ec2 create-security-group \
  --group-name alerta-alumnos-sg \
  --description "Security group para AlertaAlumnos demo" \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)
echo "Security Group creado: $SG_ID"

# Permitir SSH
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

# Permitir tráfico HTTP en 8080 para la app
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0 \
  --region us-east-1


AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
  --output text)
echo "Using AMI: $AMI_ID"

IAM_INSTANCE_PROFILE="LabInstanceProfile"
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.nano \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --iam-instance-profile Name=$IAM_INSTANCE_PROFILE \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=alerta-alumnos-instance}]' \
  --query 'Instances[0].InstanceId' \
  --output text \
  --region us-east-1)

echo "EC2 Instance creada: $INSTANCE_ID"

EC2_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text \
  --region us-east-1)

echo "Conéctate a la instancia usando:"
echo "ssh -i alerta-alumnos-key.pem ec2-user@$EC2_IP"

# Save configuration to file
cat > .env << EOF
SECURITY_GROUP_ID=$SG_ID
INSTANCE_ID=$INSTANCE_ID
TOPIC_ARN=$TOPIC_ARN
EC2_IP=$EC2_IP
KEY_FILE="${KEY_NAME}.pem"
EOF

echo "Configuration saved to alerta-config.env"
