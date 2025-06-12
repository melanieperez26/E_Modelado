FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements.txt y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . .

# Verificar que el archivo de la aplicación existe y es ejecutable
RUN test -f playground.py && echo "playground.py encontrado" || echo "ERROR: playground.py no encontrado"
RUN chmod +x playground.py

# Configurar el puerto para Cloud Run
ENV PORT 8080
EXPOSE $PORT

# Verificar que las variables de entorno necesarias están presentes
RUN if [ -z "$GROQ_API_KEY" ]; then echo "ERROR: GROQ_API_KEY no está configurada"; exit 1; fi

# Iniciar la aplicación
CMD echo "Iniciando aplicación..." && \
    echo "GROQ_API_KEY: ${GROQ_API_KEY}" && \
    echo "PORT: ${PORT}" && \
    exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 playground:app
