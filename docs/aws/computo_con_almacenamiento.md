# Computo con Storage

En este documento vamos a explorar cómo podemos utilizar servicios de cómputo en la nube junto con almacenamiento
en la nube para crear aplicaciones.

```bash
# Instalar python
export TERM=xterm-256color
sudo yum update -y
sudo yum install -y ca-certificates
sudo update-ca-trust
sudo yum install python3.13
python3.13 --version

# Configurar entorno virtual e instalar dependencias
python3.13 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8080
```
