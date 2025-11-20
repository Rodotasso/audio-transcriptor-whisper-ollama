# Script para ejecutar transcripción SIN Docker (directamente en Windows)
# Requiere Python 3.10+ instalado

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TRANSCRIPTOR SIN DOCKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python detectado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python no está instalado" -ForegroundColor Red
    Write-Host "Instala Python desde: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Verificar/crear entorno virtual
if (-not (Test-Path "venv")) {
    Write-Host ""
    Write-Host "Creando entorno virtual..." -ForegroundColor Cyan
    python -m venv venv
    Write-Host "✓ Entorno virtual creado" -ForegroundColor Green
}

# Activar entorno virtual
Write-Host ""
Write-Host "Activando entorno virtual..." -ForegroundColor Cyan
& ".\venv\Scripts\Activate.ps1"

# Instalar dependencias
Write-Host ""
Write-Host "Instalando dependencias (esto puede tardar la primera vez)..." -ForegroundColor Cyan
pip install --quiet --upgrade pip
pip install --quiet openai-whisper
pip install --quiet torch torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install --quiet google-generativeai
pip install --quiet ffmpeg-python

# Verificar FFmpeg
Write-Host ""
Write-Host "Verificando FFmpeg..." -ForegroundColor Cyan
try {
    ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "✓ FFmpeg detectado" -ForegroundColor Green
} catch {
    Write-Host "⚠ FFmpeg no está instalado" -ForegroundColor Yellow
    Write-Host "Descarga FFmpeg desde: https://ffmpeg.org/download.html" -ForegroundColor Yellow
    Write-Host "O instala con: winget install ffmpeg" -ForegroundColor Yellow
    $continue = Read-Host "¿Continuar de todas formas? (s/n)"
    if ($continue -ne "s" -and $continue -ne "S") {
        exit 1
    }
}

# Configurar variables de entorno desde .env
if (Test-Path ".env") {
    Write-Host ""
    Write-Host "Cargando configuración desde .env..." -ForegroundColor Cyan
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

# Configurar rutas locales (sin Docker)
$env:INPUT_DIR = "input"
$env:OUTPUT_DIR = "output"

# Ejecutar el script principal
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INICIANDO TRANSCRIPCIÓN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

python src\main.py

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Revisa los resultados en la carpeta 'output'" -ForegroundColor Cyan
Write-Host ""
