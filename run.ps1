# Script para construir y ejecutar el servicio de transcripción

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TRANSCRIPTOR DE AUDIO - DOCKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está instalado
try {
    docker --version | Out-Null
    Write-Host "✓ Docker detectado" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Descarga Docker desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar que existe el archivo .env
if (-not (Test-Path ".env")) {
    Write-Host "⚠ No se encontró el archivo .env" -ForegroundColor Yellow
    Write-Host "Creando .env desde .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ Archivo .env creado" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANTE: Edita el archivo .env con tu configuración antes de continuar" -ForegroundColor Yellow
    Write-Host "Especialmente si quieres formateo automático, agrega tu GOOGLE_API_KEY" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Deseas continuar con la configuración por defecto? (s/n)"
    if ($continue -ne "s" -and $continue -ne "S") {
        Write-Host "Edita .env y ejecuta este script nuevamente" -ForegroundColor Cyan
        exit 0
    }
}

# Crear directorios necesarios
Write-Host ""
Write-Host "Creando directorios necesarios..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "input" | Out-Null
New-Item -ItemType Directory -Force -Path "output" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null
Write-Host "✓ Directorios creados" -ForegroundColor Green

# Verificar archivos en input
Write-Host ""
$audioFiles = Get-ChildItem -Path "input" -File
if ($audioFiles.Count -eq 0) {
    Write-Host "⚠ No hay archivos en la carpeta 'input'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Coloca tus archivos de audio (.mp3, .wav, .m4a, etc.) en la carpeta 'input'" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Deseas continuar de todas formas? (s/n)"
    if ($continue -ne "s" -and $continue -ne "S") {
        Write-Host "Agrega archivos de audio a 'input' y ejecuta este script nuevamente" -ForegroundColor Cyan
        exit 0
    }
} else {
    Write-Host "✓ Encontrados $($audioFiles.Count) archivo(s) en 'input':" -ForegroundColor Green
    foreach ($file in $audioFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
}

# Preguntar si construir la imagen
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Opciones de ejecución:" -ForegroundColor Cyan
Write-Host "1. Construir imagen y ejecutar (primera vez o después de cambios)" -ForegroundColor White
Write-Host "2. Solo ejecutar (usar imagen existente)" -ForegroundColor White
Write-Host "3. Reconstruir completamente (sin caché)" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
$option = Read-Host "Selecciona una opción (1-3)"

switch ($option) {
    "1" {
        Write-Host ""
        Write-Host "Construyendo imagen Docker..." -ForegroundColor Cyan
        docker-compose build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Error al construir la imagen" -ForegroundColor Red
            exit 1
        }
        Write-Host "✓ Imagen construida exitosamente" -ForegroundColor Green
    }
    "2" {
        Write-Host ""
        Write-Host "Usando imagen existente..." -ForegroundColor Cyan
    }
    "3" {
        Write-Host ""
        Write-Host "Reconstruyendo imagen desde cero (sin caché)..." -ForegroundColor Cyan
        docker-compose build --no-cache
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Error al construir la imagen" -ForegroundColor Red
            exit 1
        }
        Write-Host "✓ Imagen reconstruida exitosamente" -ForegroundColor Green
    }
    default {
        Write-Host "Opción inválida. Saliendo..." -ForegroundColor Red
        exit 1
    }
}

# Ejecutar el contenedor
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Iniciando transcripción..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

docker-compose up

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Proceso completado" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Revisa los resultados en la carpeta 'output'" -ForegroundColor Green
Write-Host "Revisa los logs en la carpeta 'logs'" -ForegroundColor Green
Write-Host ""



