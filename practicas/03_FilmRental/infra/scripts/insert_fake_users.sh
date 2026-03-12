#!/bin/bash

# Nombres de los secretos en AWS Secrets Manager
SECRET_HOST="filmrentals/rds/host"
SECRET_CREDENTIALS="filmrentals/rds/credentials"

# Nombre de la base de datos
DB_NAME="filmrentals"
DB_USER="postgres"
DB_PORT=5432

export RDSHOST=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_HOST \
  --query SecretString --output text | python3 -c "import sys,json; print(json.load(sys.stdin)['host'])")

export PGPASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_CREDENTIALS \
  --query SecretString --output text | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

psql --host=$RDSHOST --port=$DB_PORT --username=$DB_USER --dbname=$DB_NAME <<EOF
INSERT INTO users (user_id, name, email) VALUES
  ('1', 'Alumno 1',   'alumno1@mail.com'),
  ('2', 'Alumno 2',   'alumno2@mail.com'),
  ('3', 'Alumno 3',  'alumno3@mail.com')
ON CONFLICT (user_id) DO NOTHING;
EOF

echo "Usuarios insertados correctamente."
