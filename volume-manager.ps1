# ============================================
# Script de Exportación/Importación de Volúmenes
# ============================================
# Permite empaquetar y restaurar los modelos descargados

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("export", "import")]
    [string]$Action,
    
    [string]$BackupDir = ".\volume-backup"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  GESTIÓN DE VOLÚMENES DOCKER" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

function Export-Volumes {
    Write-Host "[EXPORTAR] Respaldando volúmenes..." -ForegroundColor Yellow
    Write-Host ""
    
    # Crear directorio de respaldo
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Obtener el nombre del volumen de Ollama (detectar automáticamente)
    $allVolumes = docker volume ls --format "{{.Name}}"
    $volumeName = $allVolumes | Where-Object { $_ -like "*ollama-data" } | Select-Object -First 1
    
    if (-not $volumeName) {
        Write-Host "⚠️  No se encontró ningún volumen de Ollama (*ollama-data)" -ForegroundColor Yellow
        Write-Host "   Volúmenes disponibles:" -ForegroundColor Gray
        docker volume ls
        return
    }
    
    Write-Host "📦 Volumen detectado: $volumeName" -ForegroundColor Cyan
    
    # Verificar si el volumen existe
    $volumeExists = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq $volumeName }
    
    if (-not $volumeExists) {
        Write-Host "⚠️  El volumen '$volumeName' no existe. ¿Ya ejecutaste el sistema?" -ForegroundColor Yellow
        Write-Host "   Ejecuta primero: .\run.ps1" -ForegroundColor Gray
        return
    }
    
    Write-Host "[1/2] Exportando volumen de Ollama..." -ForegroundColor Yellow
    Write-Host "  Volumen: $volumeName" -ForegroundColor Gray
    
    # Exportar usando un contenedor temporal
    $tarFile = Join-Path $BackupDir "ollama-data.tar"
    docker run --rm `
        -v ${volumeName}:/source `
        -v ${BackupDir}:/backup `
        alpine `
        tar czf /backup/ollama-data.tar.gz -C /source .
    
    if ($LASTEXITCODE -eq 0) {
        $fileSize = (Get-Item "$BackupDir\ollama-data.tar.gz").Length / 1MB
        Write-Host "  ✅ Exportado: ollama-data.tar.gz ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Error exportando volumen" -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "[2/2] Creando manifiesto..." -ForegroundColor Yellow
    
    $manifest = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        volumes = @(
            @{
                name = $volumeName
                file = "ollama-data.tar.gz"
                size_mb = [math]::Round($fileSize, 2)
            }
        )
        docker_version = (docker version --format '{{.Server.Version}}')
    } | ConvertTo-Json -Depth 10
    
    Set-Content -Path (Join-Path $BackupDir "manifest.json") -Value $manifest
    Write-Host "  ✅ Manifiesto creado" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  EXPORTACIÓN COMPLETA" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📦 Respaldo guardado en: $BackupDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para compartir este respaldo:" -ForegroundColor Yellow
    Write-Host "  1. Comprimir: Compress-Archive -Path '$BackupDir' -DestinationPath 'models-backup.zip'" -ForegroundColor White
    Write-Host "  2. Compartir el archivo .zip" -ForegroundColor White
    Write-Host "  3. Importar con: .\volume-manager.ps1 -Action import -BackupDir <ruta-extraída>" -ForegroundColor White
    Write-Host ""
}

function Import-Volumes {
    Write-Host "[IMPORTAR] Restaurando volúmenes..." -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar que existe el directorio de respaldo
    if (-not (Test-Path $BackupDir)) {
        Write-Host "❌ El directorio de respaldo no existe: $BackupDir" -ForegroundColor Red
        return
    }
    
    # Verificar que existe el archivo tar
    $tarFile = Join-Path $BackupDir "ollama-data.tar.gz"
    if (-not (Test-Path $tarFile)) {
        Write-Host "❌ No se encontró el archivo: ollama-data.tar.gz" -ForegroundColor Red
        return
    }
    
    # Leer manifiesto si existe
    $manifestFile = Join-Path $BackupDir "manifest.json"
    if (Test-Path $manifestFile) {
        $manifest = Get-Content $manifestFile | ConvertFrom-Json
        Write-Host "📋 Manifiesto encontrado:" -ForegroundColor Cyan
        Write-Host "  Fecha: $($manifest.timestamp)" -ForegroundColor Gray
        Write-Host "  Tamaño: $($manifest.volumes[0].size_mb) MB" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "[1/3] Deteniendo servicios..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "  ✅ Servicios detenidos" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[2/3] Creando volumen si no existe..." -ForegroundColor Yellow
    # Detectar nombre del volumen desde docker-compose
    $composeProject = (Get-Location).Path.Split('\')[-1].ToLower() -replace '[^a-z0-9]',''
    $volumeName = "${composeProject}_ollama-data"
    
    docker volume create $volumeName | Out-Null
    Write-Host "  ✅ Volumen: $volumeName" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[3/3] Importando datos..." -ForegroundColor Yellow
    Write-Host "  ⏳ Esto puede tomar algunos minutos..." -ForegroundColor Gray
    
    # Importar usando un contenedor temporal
    docker run --rm `
        -v ${volumeName}:/target `
        -v ${BackupDir}:/backup `
        alpine `
        sh -c "cd /target && tar xzf /backup/ollama-data.tar.gz"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Datos importados exitosamente" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Error importando datos" -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  IMPORTACIÓN COMPLETA" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Modelos restaurados exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ahora puedes iniciar el sistema:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1" -ForegroundColor White
    Write-Host ""
}

# Ejecutar acción
switch ($Action) {
    "export" { Export-Volumes }
    "import" { Import-Volumes }
}
