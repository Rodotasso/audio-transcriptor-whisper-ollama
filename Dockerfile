# Dockerfile para servicio de transcripción de audio con Whisper
FROM python:3.10-slim

# Instalar dependencias del sistema (FFmpeg es esencial para procesar audio)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Establecer directorio de trabajo
WORKDIR /app

# Copiar requirements y instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Instalar Whisper desde el repositorio oficial
RUN pip install --no-cache-dir git+https://github.com/openai/whisper.git

# PRE-DESCARGAR MODELOS DE WHISPER para reproducibilidad
# Esto hace la imagen más grande (~5GB) pero completamente autónoma
RUN python -c "import whisper; whisper.load_model('tiny')"
RUN python -c "import whisper; whisper.load_model('base')"
RUN python -c "import whisper; whisper.load_model('small')"
RUN python -c "import whisper; whisper.load_model('medium')"
# Descomentar si necesitas el modelo large (~10GB adicionales):
# RUN python -c "import whisper; whisper.load_model('large')"

# Copiar scripts de la aplicación
COPY src/ ./src/

# Crear directorios para entrada/salida
RUN mkdir -p /app/input /app/output /app/logs

# Variable de entorno para el modelo de Whisper (por defecto: medium)
ENV WHISPER_MODEL=medium
ENV PYTHONUNBUFFERED=1

# Comando por defecto (puede ser sobreescrito)
CMD ["python", "src/main.py"]
