from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

tareas = []

class Tarea(BaseModel):
    titulo: str

@app.get("/tareas")
def obtener_tareas():
    return tareas

@app.post("/tareas")
def agregar_tarea(tarea: Tarea):
    tareas.append({"id": len(tareas) + 1, "titulo": tarea.titulo})
    return tareas[-1]

@app.delete("/tareas/{id}")
def eliminar_tarea(id: int):
    for t in tareas:
        if t["id"] == id:
            tareas.remove(t)
            return {"mensaje": "eliminada"}
    raise HTTPException(status_code=404, detail="No encontrada")
