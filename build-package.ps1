# ============================================
# Script de Empaquetado Completo
# ============================================
# Construye y exporta el sistema completo para distribución

param(
    [switch]$IncludeLarge,  # Incluir modelo Whisper large
    [switch]$ExportImages,  # Exportar imágenes Docker como .tar
    [string]$OutputDir = ".\package"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  EMPAQUETADOR DE SISTEMA COMPLETO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker disponible" -ForegroundColor Green
Write-Host ""

# Crear directorio de salida
Write-Host "[2/6] Creando directorio de paquete..." -ForegroundColor Yellow
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
Write-Host "✅ Directorio: $OutputDir" -ForegroundColor Green
Write-Host ""

# Construir imagen con modelos pre-descargados
Write-Host "[3/6] Construyendo imagen Docker (esto puede tomar 10-20 minutos)..." -ForegroundColor Yellow
Write-Host "⚠️  La imagen incluirá modelos Whisper: tiny, base, small, medium" -ForegroundColor Yellow

if ($IncludeLarge) {
    Write-Host "⚠️  También incluirá el modelo 'large' (~3GB adicionales)" -ForegroundColor Yellow
    # Descomentar línea en Dockerfile
    $dockerfileContent = Get-Content Dockerfile -Raw
    $dockerfileContent = $dockerfileContent -replace '# RUN python -c "import whisper; whisper.load_model\(''large''\)"', 'RUN python -c "import whisper; whisper.load_model(''large'')"'
    Set-Content -Path Dockerfile.tmp -Value $dockerfileContent
    docker-compose build
    Remove-Item Dockerfile.tmp -Force
} else {
    docker-compose build
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo la imagen" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen construida exitosamente" -ForegroundColor Green
Write-Host ""

# Pre-descargar modelo de Ollama
Write-Host "[4/6] Pre-descargando modelo Ollama..." -ForegroundColor Yellow
Write-Host "Iniciando servicio Ollama temporalmente..." -ForegroundColor Gray
docker-compose up -d ollama
Start-Sleep -Seconds 10

$ollamaModel = "llama3.2:3b"
if (Test-Path .env) {
    $envContent = Get-Content .env
    $modelLine = $envContent | Where-Object { $_ -match "^OLLAMA_MODEL=" }
    if ($modelLine) {
        $ollamaModel = ($modelLine -split "=")[1].Trim()
    }
}

Write-Host "Descargando modelo: $ollamaModel" -ForegroundColor Gray
docker exec transcripcion-ollama-1 ollama pull $ollamaModel

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Modelo Ollama descargado" -ForegroundColor Green
} else {
    Write-Host "⚠️  Error descargando modelo, pero continuando..." -ForegroundColor Yellow
}

docker-compose down
Write-Host ""

# Exportar imágenes Docker
if ($ExportImages) {
    Write-Host "[5/6] Exportando imágenes Docker..." -ForegroundColor Yellow
    
    Write-Host "Exportando audio-transcriber..." -ForegroundColor Gray
    docker save transcripcion-audio-transcriber:latest -o "$OutputDir\audio-transcriber.tar"
    
    Write-Host "Exportando ollama..." -ForegroundColor Gray
    docker save ollama/ollama:latest -o "$OutputDir\ollama.tar"
    
    Write-Host "✅ Imágenes exportadas" -ForegroundColor Green
} else {
    Write-Host "[5/6] Saltando exportación de imágenes (usa -ExportImages para incluirlas)" -ForegroundColor Yellow
}
Write-Host ""

# Copiar archivos del proyecto
Write-Host "[6/6] Copiando archivos del proyecto..." -ForegroundColor Yellow

$filesToCopy = @(
    "docker-compose.yml",
    "Dockerfile",
    "requirements.txt",
    ".env.example",
    "README.md",
    "QUICKSTART.md",
    "PROYECTO.md",
    "WORKFLOW.md",
    "run.ps1",
    "verify.ps1",
    "clean.ps1"
)

foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file -Destination $OutputDir -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
    }
}

# Copiar directorio src
if (Test-Path "src") {
    Copy-Item -Path "src" -Destination "$OutputDir\src" -Recurse -Force
    Write-Host "  ✓ src/" -ForegroundColor Gray
}

# Crear directorios vacíos
foreach ($dir in @("input", "output", "logs")) {
    $targetDir = Join-Path $OutputDir $dir
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    # Crear .gitkeep
    Set-Content -Path (Join-Path $targetDir ".gitkeep") -Value ""
    Write-Host "  ✓ $dir/" -ForegroundColor Gray
}

Write-Host "✅ Archivos copiados" -ForegroundColor Green
Write-Host ""

# Crear README de instalación
$installReadme = @"
# INSTALACIÓN DEL PAQUETE

## Requisitos Previos
- Docker Desktop instalado
- Al menos 8GB de RAM disponible
- ~10GB de espacio en disco

## Opción 1: Con imágenes pre-construidas (si se exportaron)

1. Cargar imágenes Docker:
``````powershell
docker load -i audio-transcriber.tar
docker load -i ollama.tar
``````

2. Copiar .env.example a .env:
``````powershell
Copy-Item .env.example .env
``````

3. Ejecutar:
``````powershell
.\run.ps1
``````

## Opción 2: Construcción desde código

1. Copiar .env.example a .env:
``````powershell
Copy-Item .env.example .env
``````

2. Construir imágenes:
``````powershell
docker-compose build
``````

3. Ejecutar:
``````powershell
.\run.ps1
``````

## Uso Rápido

1. Coloca archivos de audio en la carpeta \`input/\`
2. Ejecuta \`.\run.ps1\`
3. Encuentra las transcripciones en \`output/\`

## Configuración

Edita el archivo \`.env\` para cambiar:
- \`WHISPER_MODEL\`: tiny, base, small, medium, large
- \`OLLAMA_MODEL\`: llama3.2:3b, llama3.2:1b, llama3:8b
- \`MODE\`: full, transcribe-only, format-only

Ver \`README.md\` para documentación completa.
"@

Set-Content -Path "$OutputDir\INSTALL.md" -Value $installReadme
Write-Host "✅ Documentación de instalación creada" -ForegroundColor Green
Write-Host ""

# Resumen
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  EMPAQUETADO COMPLETO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Paquete creado en: $OutputDir" -ForegroundColor Green
Write-Host ""
Write-Host "Contenido del paquete:" -ForegroundColor Yellow

$packageSize = (Get-ChildItem $OutputDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
Write-Host "  • Código fuente y configuración" -ForegroundColor White
Write-Host "  • Modelos Whisper pre-descargados" -ForegroundColor White
Write-Host "  • Scripts de automatización" -ForegroundColor White
Write-Host "  • Documentación completa" -ForegroundColor White

if ($ExportImages) {
    Write-Host "  • Imágenes Docker exportadas (.tar)" -ForegroundColor White
    Write-Host ""
    Write-Host "Tamaño total: $([math]::Round($packageSize, 2)) GB" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Sin imágenes Docker (usa -ExportImages para incluirlas)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Para distribuir:" -ForegroundColor Yellow
Write-Host "  1. Comprimir carpeta: Compress-Archive -Path '$OutputDir' -DestinationPath 'transcriptor-package.zip'" -ForegroundColor White
Write-Host "  2. Compartir el archivo .zip" -ForegroundColor White
Write-Host "  3. El destinatario sigue las instrucciones en INSTALL.md" -ForegroundColor White
Write-Host ""
