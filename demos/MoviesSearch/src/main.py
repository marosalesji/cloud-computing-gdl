import logging
import psycopg2

from fastapi import FastAPI, Query, HTTPException
from typing import Optional
from aws_secrets import get_db_credentials

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()


def get_db_connection():
    creds = get_db_credentials()
    try:
        return psycopg2.connect(
            host=creds["host"],
            port=creds.get("port", 5432),
            dbname=creds["dbname"],
            user=creds["username"],
            password=creds["password"]
        )
    except psycopg2.OperationalError as e:
        logger.error(f"No se pudo conectar a la base de datos: {e}")
        raise HTTPException(status_code=503, detail="No se pudo conectar a la base de datos")


@app.get("/movies")
def search_movies(
    genre: Optional[str] = Query(None),
    title: Optional[str] = Query(None)
):
    if not genre and not title:
        return {"error": "Debes proporcionar al menos un parámetro: genre o title"}

    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            if genre and title:
                cur.execute("""
                    SELECT movie_id, title, genres
                    FROM movies
                    WHERE genres ILIKE %s AND title ILIKE %s
                    ORDER BY title
                    LIMIT 1
                """, (f"%{genre}%", f"%{title}%"))
            elif genre:
                cur.execute("""
                    SELECT movie_id, title, genres
                    FROM movies
                    WHERE genres ILIKE %s
                    ORDER BY title
                    LIMIT 1
                """, (f"%{genre}%",))
            else:
                cur.execute("""
                    SELECT movie_id, title, genres
                    FROM movies
                    WHERE title ILIKE %s
                    ORDER BY title
                    LIMIT 1
                """, (f"%{title}%",))

            rows = cur.fetchall()
            return {
                "total": len(rows),
                "movies": [
                    {
                        "movie_id": r[0],
                        "title": r[1],
                        "genres": r[2].split("|") if r[2] else []
                    }
                    for r in rows
                ]
            }
    finally:
        conn.close()


@app.get("/health")
def health():
    return {"status": "ok"}
