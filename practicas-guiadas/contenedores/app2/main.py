from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json, os

app = FastAPI()

ARCHIVO = "/data/tareas.json"

def cargar():
    if os.path.exists(ARCHIVO):
        with open(ARCHIVO) as f:
            return json.load(f)
    return []

def guardar(tareas):
    with open(ARCHIVO, "w") as f:
        json.dump(tareas, f)

class Tarea(BaseModel):
    titulo: str

@app.get("/tareas")
def obtener_tareas():
    return cargar()

@app.post("/tareas")
def agregar_tarea(tarea: Tarea):
    tareas = cargar()
    tareas.append({"id": len(tareas) + 1, "titulo": tarea.titulo})
    guardar(tareas)
    return tareas[-1]

@app.delete("/tareas/{id}")
def eliminar_tarea(id: int):
    tareas = cargar()
    for t in tareas:
        if t["id"] == id:
            tareas.remove(t)
            guardar(tareas)
            return {"mensaje": "eliminada"}
    raise HTTPException(status_code=404, detail="No encontrada")
