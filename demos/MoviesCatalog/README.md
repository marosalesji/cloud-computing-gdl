# Movies Catalog

Este demo muestra la interacción entre una aplicación web y una base de datos relacional Amazon RDS.

## Crear recursos

Es necesario crear una instancia de Amazon RDS con PostgreSQL y una instancia de Amazon EC2 para alojar la
aplicación web.

```
export AWS_PAGER=cat
```


### Crear Security Groups

Vamos a necesitar crear security groups para la instancia de EC2 y para la instancia de RDS,
incluyendo reglas de ingreso para permitir el tráfico entre ambos y desde el exterior hacia la aplicación web.

```
# Guardamos el id del VPC default en una variable de entorno para usarlo posteriormente
export VPCID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)

# Creamos un security group para la instancia de EC2 y guardamos su id en una variable de entorno
aws ec2 create-security-group \
  --group-name demo-movies-ec2-sg \
  --description "SG for EC2 Movies Catalog Client" \
  --vpc-id $VPCID
export SGEC2=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=demo-movies-ec2-sg" --query "SecurityGroups[0].GroupId" --output text)

# Agregamos reglas de ingreso al security group de EC2 para permitir tráfico SSH y HTTP desde cualquier origen
aws ec2 authorize-security-group-ingress --group-id $SGEC2 --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGEC2 --protocol tcp --port 8080 --cidr 0.0.0.0/0

# Creamos un security group para la instancia de RDS y guardamos su id en una variable de entorno
aws ec2 create-security-group \
  --group-name demo-movies-rds-sg \
  --description "SG for RDS PostgreSQL demo" \
  --vpc-id $VPCID
export SGRDS=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=demo-movies-rds-sg" --query "SecurityGroups[0].GroupId" --output text)

# Agregar regla de ingreso al security group de RDS para permitir tráfico desde el security group de EC2
aws ec2 authorize-security-group-ingress \
  --group-id $SGRDS \
  --source-group $SGEC2 \
  --protocol tcp \
  --port 5432

```

Como estamos usando variables de ambiente, más adelante podremos usar `$SGEC2` y `$SGRDS` para referirnos a los
security groups que acabamos de crear.


### Crear instancia EC2

```
# Crear par de claves
aws ec2 create-key-pair \
  --key-name demo-movies-key \
  --query 'KeyMaterial' \
  --output text > demo-movies-key.pem
chmod 400 demo-movies-key.pem


# Crear una instancia EC2
aws ec2 run-instances \
    --image-id ami-0b6c6ebed2801a5cb \
    --count 1 \
    --instance-type t3.micro \
    --key-name demo-movies-key \
    --security-groups demo-movies-ec2-sg \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=movies-catalog}]'

# Ver IP pública de la instancia EC2
EC2IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=movies-catalog" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text \
  --region us-east-1)
echo "Public IP de la instancia EC2: $EC2IP"
```


### Crear instancia RDS

Creamos el RDS PostgreSQL usando el security group creado anteriormente para RDS.
Este Security Group permite el acceso desde la instancia EC2 que creamos antes al puerto 5432 (PostgreSQL)
y bloquea el acceso público.

```
# Crear instancia RDS PostgreSQL
export RDSPASS="Password123!"
aws rds create-db-instance \
  --db-instance-identifier demo-moviescat-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 18.1 \
  --allocated-storage 20 \
  --master-username postgres \
  --master-user-password $RDSPASS \
  --db-name moviescat \
  --no-publicly-accessible \
  --vpc-security-group-ids $SGRDS \
  --backup-retention-period 0 \
  --region us-east-1
```

## Descargar dataset de peliculas

En tu entorno local descarga el dataset de MovieLens

```
curl -L -# -o movielens.zip -O https://files.grouplens.org/datasets/movielens/ml-latest-small.zip
```

## App en EC2

Esta EC2 esta usando una imagen con ubuntu
```
scp -i demo-movies-key.pem movielens.zip   ubuntu@${EC2IP}:/home/ubuntu/
ssh -i demo-movies-key.pem ubuntu@${EC2IP}
```

En la instancia de EC2 instalar el cliente de PostgreSQL

```
sudo apt update
sudo apt install -y unzip
sudo apt install postgresql-client-15
unzip movielens.zip
```

Conectarse a la base de datos RDS desde la instancia de EC2

```
# Buscar el endpoint de RDS en la consola
export RDSHOST="demo-moviescat-db.<buscar-en-la-consola>.us-east-1.rds.amazonaws.com"

# Conectarse a la base de datos usando el cliente psql
psql --host=$RDSHOST --port=5432 --username=postgres --password --dbname=moviescat
```

A través del cliente psql, crear la tabla de movies e importar los datos desde el archivo CSV que se encuentra en la instancia de EC2.
```

CREATE TABLE movies (
    movieId     INTEGER PRIMARY KEY,
    title       TEXT NOT NULL,
    genres      TEXT
);




ALTER TABLE movies
ALTER COLUMN movieid ADD GENERATED ALWAYS AS IDENTITY;
SELECT setval(pg_get_serial_sequence('movies','movieid'), (SELECT MAX(movieid) FROM movies));


\copy movies FROM '/home/ubuntu/ml-latest-small/movies.csv' DELIMITER ',' CSV HEADER;


# Ya podemos hacer consultas - el resultado es 3756
SELECT COUNT(*) FROM movies WHERE genres ILIKE '%comedy%';
```

## Referencias
- [MovieLens Dataset](https://grouplens.org/datasets/movielens/)
- [Instalacion Linux Postgres](https://www.postgresql.org/download/linux/ubuntu/)
