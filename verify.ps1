# Script de verificación del sistema

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN DEL SISTEMA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 1. Verificar Docker
Write-Host "1. Verificando Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "   ✓ Docker instalado: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker no responde"
    }
} catch {
    Write-Host "   ✗ Docker no está instalado o no funciona correctamente" -ForegroundColor Red
    Write-Host "     Instala Docker desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    $allGood = $false
}

# 2. Verificar Docker Compose
Write-Host ""
Write-Host "2. Verificando Docker Compose..." -ForegroundColor Cyan
try {
    $composeVersion = docker-compose --version 2>$null
    if ($composeVersion) {
        Write-Host "   ✓ Docker Compose instalado: $composeVersion" -ForegroundColor Green
    } else {
        throw "Docker Compose no responde"
    }
} catch {
    Write-Host "   ✗ Docker Compose no está disponible" -ForegroundColor Red
    $allGood = $false
}

# 3. Verificar estructura de archivos
Write-Host ""
Write-Host "3. Verificando estructura de archivos..." -ForegroundColor Cyan

$requiredFiles = @(
    "Dockerfile",
    "docker-compose.yml",
    "requirements.txt",
    ".env.example",
    "src\main.py",
    "src\transcribe.py",
    "src\format.py"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Falta: $file" -ForegroundColor Red
        $allGood = $false
    }
}

# 4. Verificar directorios
Write-Host ""
Write-Host "4. Verificando directorios..." -ForegroundColor Cyan

$requiredDirs = @("input", "output", "logs", "src")

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir -PathType Container) {
        Write-Host "   ✓ $dir/" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Creando directorio: $dir/" -ForegroundColor Yellow
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "   ✓ Directorio creado" -ForegroundColor Green
    }
}

# 5. Verificar archivo .env
Write-Host ""
Write-Host "5. Verificando configuración..." -ForegroundColor Cyan

if (Test-Path ".env") {
    Write-Host "   ✓ Archivo .env existe" -ForegroundColor Green
    
    # Leer contenido del .env
    $envContent = Get-Content ".env" -Raw
    
    # Verificar configuraciones importantes
    if ($envContent -match "WHISPER_MODEL=(\w+)") {
        $model = $matches[1]
        Write-Host "   ℹ Modelo Whisper: $model" -ForegroundColor Cyan
    }
    
    if ($envContent -match "AUDIO_LANGUAGE=(\w+)") {
        $lang = $matches[1]
        Write-Host "   ℹ Idioma: $lang" -ForegroundColor Cyan
    }
    
    if ($envContent -match "GOOGLE_API_KEY=(.+)") {
        $apiKey = $matches[1].Trim()
        if ($apiKey -and $apiKey -ne "") {
            Write-Host "   ✓ Google API Key configurada" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Google API Key no configurada (formateo deshabilitado)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   ⚠ Archivo .env no existe" -ForegroundColor Yellow
    Write-Host "   ℹ Creando desde .env.example..." -ForegroundColor Cyan
    Copy-Item .env.example .env
    Write-Host "   ✓ Archivo .env creado (edítalo con tu configuración)" -ForegroundColor Green
}

# 6. Verificar archivos de entrada
Write-Host ""
Write-Host "6. Verificando archivos de entrada..." -ForegroundColor Cyan

$inputFiles = Get-ChildItem -Path "input" -File -Exclude "README.md" 2>$null
if ($inputFiles -and $inputFiles.Count -gt 0) {
    Write-Host "   ✓ Encontrados $($inputFiles.Count) archivo(s) para procesar:" -ForegroundColor Green
    foreach ($file in $inputFiles | Select-Object -First 5) {
        Write-Host "     - $($file.Name)" -ForegroundColor Gray
    }
    if ($inputFiles.Count -gt 5) {
        Write-Host "     ... y $($inputFiles.Count - 5) más" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠ No hay archivos en la carpeta 'input'" -ForegroundColor Yellow
    Write-Host "     Agrega archivos de audio antes de ejecutar" -ForegroundColor Gray
}

# 7. Verificar espacio en disco
Write-Host ""
Write-Host "7. Verificando espacio en disco..." -ForegroundColor Cyan

$drive = (Get-Location).Drive
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)

if ($freeSpaceGB -gt 10) {
    Write-Host "   ✓ Espacio libre: $freeSpaceGB GB" -ForegroundColor Green
} elseif ($freeSpaceGB -gt 5) {
    Write-Host "   ⚠ Espacio libre: $freeSpaceGB GB (puede ser insuficiente)" -ForegroundColor Yellow
} else {
    Write-Host "   ✗ Espacio libre: $freeSpaceGB GB (insuficiente)" -ForegroundColor Red
    $allGood = $false
}

# Resumen final
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "  ✓ SISTEMA LISTO PARA USAR" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Siguiente paso:" -ForegroundColor White
    Write-Host "  1. Coloca archivos de audio en la carpeta 'input'" -ForegroundColor Gray
    Write-Host "  2. Ejecuta: .\run.ps1" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "  ⚠ SISTEMA CON PROBLEMAS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Revisa los errores marcados arriba y corrígelos antes de continuar" -ForegroundColor Yellow
    Write-Host ""
}
