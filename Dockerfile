FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements.txt y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --index-url https://pypi.agno.com/simple --extra-index-url https://pypi.org/simple agno==0.1.2 \
    && python -c "import agno; print('Agno version:', agno.__version__)"

# Copiar el resto del código
COPY . .

# Verificar que el archivo de la aplicación existe
RUN test -f playground.py && echo "playground.py encontrado" || echo "ERROR: playground.py no encontrado"

# Exponer el puerto 3000 
EXPOSE 3000

# Iniciar la aplicación
CMD echo "Iniciando aplicación..." && \
    echo "GROQ_API_KEY: ${GROQ_API_KEY}" && \
    echo "PORT: ${PORT}" && \
    exec gunicorn --bind :3000 --workers 1 --threads 8 --timeout 0 playground:app
