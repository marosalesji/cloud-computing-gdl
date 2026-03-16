#!/bin/bash
set -e

# Cargar variables de ambiente
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

export AWS_PAGER=cat

echo "Obteniendo VPC default..."
export VPCID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query "Vpcs[0].VpcId" \
  --output text)
echo "VPC: $VPCID"

echo "Creando security group para RDS..."
aws ec2 create-security-group \
  --group-name $SGRDSNAME \
  --description "SG for RDS MoviesSearch" \
  --vpc-id $VPCID

export SGRDS=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$SGRDSNAME" \
  --query "SecurityGroups[0].GroupId" \
  --output text)
echo "SG RDS: $SGRDS"

echo "Abriendo puerto 5432 al mundo (solo para demo local)..."
aws ec2 authorize-security-group-ingress \
  --group-id $SGRDS \
  --protocol tcp \
  --port 5432 \
  --cidr 0.0.0.0/0

echo "Creando instancia RDS PostgreSQL..."
aws rds create-db-instance \
  --db-instance-identifier $RDSIDENTIFIER \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16 \
  --allocated-storage 20 \
  --master-username $RDSUSER \
  --master-user-password $RDSPASS \
  --db-name $RDSDB \
  --publicly-accessible \
  --vpc-security-group-ids $SGRDS \
  --backup-retention-period 0 \
  --region us-east-1

echo "Esperando que RDS esté disponible (puede tomar 5-10 minutos)..."
aws rds wait db-instance-available \
  --db-instance-identifier $RDSIDENTIFIER

export RDSHOST=$(aws rds describe-db-instances \
  --db-instance-identifier $RDSIDENTIFIER \
  --query "DBInstances[0].Endpoint.Address" \
  --output text)

echo "RDS listo en: $RDSHOST"
echo ""
echo "Guarda este valor, lo necesitarás para el setup de la DB:"
echo "export RDSHOST=$RDSHOST"
