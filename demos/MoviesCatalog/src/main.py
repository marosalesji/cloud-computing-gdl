import os
import uvicorn
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import psycopg2

app = FastAPI()

RDSHOST = os.environ.get("RDSHOST")
RDSPASS = os.environ.get("RDSPASS")

def get_comedy_count():
    conn = psycopg2.connect(
        host=RDSHOST,
        port=5432,
        dbname="moviescat",
        user="postgres",
        password=RDSPASS,
        sslmode="require"
    )
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM movies WHERE genres ILIKE '%comedy%';")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    return count

@app.get("/comedy")
def comedy_count():
    return {"count": get_comedy_count()}

@app.get("/", response_class=HTMLResponse)
def home():
    with open("index.html", "r") as f:
        return f.read()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
