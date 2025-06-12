FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements.txt y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --index-url https://pypi.agno.com/simple --extra-index-url https://pypi.org/simple agno==0.1.2

# Copiar el resto del código
COPY . .

# Exponer el puerto 8080 
EXPOSE 8080

# Iniciar la aplicación
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 playground:app
