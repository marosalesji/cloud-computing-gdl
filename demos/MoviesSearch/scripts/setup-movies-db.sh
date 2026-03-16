#!/bin/bash
set -e

# Cargar variables de ambiente
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

# RDSHOST es el único valor que no viene del .env
# porque se obtiene después de correr setup-rds.sh
if [ -z "$RDSHOST" ]; then
  echo "Error: RDSHOST no está definido."
  echo "Córrelo así: RDSHOST=<endpoint> bash setup-movies-db.sh"
  exit 1
fi

echo "Instalando dependencias..."
if command -v apt &>/dev/null; then
  sudo apt update -y
  sudo apt install -y unzip postgresql-client-16
elif command -v pacman &>/dev/null; then
  sudo pacman -S --noconfirm unzip postgresql
else
  echo "Package manager no reconocido. Instala psql manualmente."
  exit 1
fi

echo "Descargando dataset de MovieLens..."
curl -L -# -o movielens.zip https://files.grouplens.org/datasets/movielens/ml-latest-small.zip
unzip -o movielens.zip

echo "Creando tabla movies..."
PGPASSWORD=$RDSPASS psql \
  --host=$RDSHOST \
  --port=5432 \
  --username=$RDSUSER \
  --dbname=$RDSDB \
  --command="CREATE TABLE IF NOT EXISTS movies (
    movie_id INTEGER PRIMARY KEY,
    title    TEXT NOT NULL,
    genres   TEXT
  );"

echo "Cargando datos de MovieLens..."
PGPASSWORD=$RDSPASS psql \
  --host=$RDSHOST \
  --port=5432 \
  --username=$RDSUSER \
  --dbname=$RDSDB \
  --command="\copy movies(movie_id, title, genres) FROM 'ml-latest-small/movies.csv' DELIMITER ',' CSV HEADER"

echo "Verificando carga..."
PGPASSWORD=$RDSPASS psql \
  --host=$RDSHOST \
  --port=5432 \
  --username=$RDSUSER \
  --dbname=$RDSDB \
  --command="SELECT COUNT(*) FROM movies;"

echo "Setup completado."
