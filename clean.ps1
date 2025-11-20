# Script de limpieza para reiniciar el entorno

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  LIMPIEZA DEL ENTORNO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Este script va a:" -ForegroundColor White
Write-Host "  1. Detener y eliminar contenedores" -ForegroundColor Gray
Write-Host "  2. Limpiar archivos de output y logs" -ForegroundColor Gray
Write-Host "  3. Opcionalmente eliminar archivos de input" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "¿Deseas continuar? (s/n)"
if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "Operación cancelada" -ForegroundColor Cyan
    exit 0
}

# Detener y eliminar contenedores
Write-Host ""
Write-Host "Deteniendo contenedores..." -ForegroundColor Cyan
docker-compose down 2>$null
Write-Host "✓ Contenedores detenidos" -ForegroundColor Green

# Limpiar output
if (Test-Path "output") {
    Write-Host ""
    Write-Host "Limpiando carpeta output..." -ForegroundColor Cyan
    Remove-Item -Path "output\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "✓ Output limpiado" -ForegroundColor Green
}

# Limpiar logs
if (Test-Path "logs") {
    Write-Host ""
    Write-Host "Limpiando carpeta logs..." -ForegroundColor Cyan
    Remove-Item -Path "logs\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "✓ Logs limpiados" -ForegroundColor Green
}

# Preguntar si limpiar input
Write-Host ""
$cleanInput = Read-Host "¿Deseas limpiar también la carpeta input? (s/n)"
if ($cleanInput -eq "s" -or $cleanInput -eq "S") {
    if (Test-Path "input") {
        Write-Host "Limpiando carpeta input..." -ForegroundColor Cyan
        Remove-Item -Path "input\*" -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "✓ Input limpiado" -ForegroundColor Green
    }
}

# Preguntar si eliminar la imagen Docker
Write-Host ""
$removeImage = Read-Host "¿Deseas eliminar también la imagen Docker? (s/n)"
if ($removeImage -eq "s" -or $removeImage -eq "S") {
    Write-Host "Eliminando imagen Docker..." -ForegroundColor Cyan
    docker-compose down --rmi all 2>$null
    Write-Host "✓ Imagen eliminada" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
