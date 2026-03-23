import time
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2, os

app = FastAPI()

def conectar():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        dbname=os.getenv("DB_NAME", "tareas"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASS", "password123")
    )

def init_db():
    for i in range(10):
        try:
            conn = conectar()
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE IF NOT EXISTS tareas (
                    id SERIAL PRIMARY KEY,
                    titulo VARCHAR(100)
                )
            """)
            conn.commit()
            cur.close()
            conn.close()
            print("DB lista")
            return
        except Exception as e:
            print(f"Esperando DB... intento {i+1}")
            time.sleep(2)
    raise Exception("No se pudo conectar a la DB")

@app.on_event("startup")
def startup():
    init_db()

class Tarea(BaseModel):
    titulo: str

@app.get("/tareas")
def obtener_tareas():
    conn = conectar()
    cur = conn.cursor()
    cur.execute("SELECT id, titulo FROM tareas")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [{"id": r[0], "titulo": r[1]} for r in rows]

@app.post("/tareas")
def agregar_tarea(tarea: Tarea):
    conn = conectar()
    cur = conn.cursor()
    cur.execute("INSERT INTO tareas (titulo) VALUES (%s) RETURNING id, titulo", (tarea.titulo,))
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return {"id": row[0], "titulo": row[1]}

@app.delete("/tareas/{id}")
def eliminar_tarea(id: int):
    conn = conectar()
    cur = conn.cursor()
    cur.execute("DELETE FROM tareas WHERE id = %s RETURNING id", (id,))
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="No encontrada")
    return {"mensaje": "eliminada"}
