# ============================================================================
# Script de Gestión del Transcriptor de Audio con Whisper + Ollama
# ============================================================================

function Show-Banner {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  🎙️  TRANSCRIPTOR DE AUDIO" -ForegroundColor Cyan
    Write-Host "  Whisper + Ollama (100% Local)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-MainMenu {
    Show-Banner
    Write-Host "MENÚ PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 🚀 Transcribir y Formatear (Proceso Completo)" -ForegroundColor White
    Write-Host "2. 🎤 Solo Transcribir (Whisper)" -ForegroundColor White
    Write-Host "3. ✨ Solo Formatear (Ollama)" -ForegroundColor White
    Write-Host "4. 🔧 Configuración y Mantenimiento" -ForegroundColor White
    Write-Host "5. 📊 Ver Estado del Sistema" -ForegroundColor White
    Write-Host "6. 🗑️  Limpiar Archivos de Salida" -ForegroundColor White
    Write-Host "7. ❌ Salir" -ForegroundColor White
    Write-Host ""
}

function Show-ConfigMenu {
    Show-Banner
    Write-Host "CONFIGURACIÓN Y MANTENIMIENTO" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 🏗️  Primera Instalación (Construir todo)" -ForegroundColor White
    Write-Host "2. 🔄 Reconstruir Imagen (con cambios de código)" -ForegroundColor White
    Write-Host "3. ⚙️  Editar archivo .env" -ForegroundColor White
    Write-Host "4. 📥 Descargar/Actualizar modelo Ollama" -ForegroundColor White
    Write-Host "5. 🧹 Limpieza Completa (volúmenes y contenedores)" -ForegroundColor White
    Write-Host "6. ⬅️  Volver al menú principal" -ForegroundColor White
    Write-Host ""
}

function Test-Docker {
    try {
        docker --version | Out-Null
        return $true
    } catch {
        Write-Host "✗ Docker no está instalado o no está en el PATH" -ForegroundColor Red
        Write-Host "Descarga Docker desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
}

function Initialize-Directories {
    Write-Host "Verificando directorios..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "input" | Out-Null
    New-Item -ItemType Directory -Force -Path "output" | Out-Null
    New-Item -ItemType Directory -Force -Path "logs" | Out-Null
    Write-Host "✓ Directorios verificados" -ForegroundColor Green
}

function Test-EnvFile {
    if (-not (Test-Path ".env")) {
        Write-Host "⚠ No se encontró el archivo .env" -ForegroundColor Yellow
        if (Test-Path ".env.example") {
            Write-Host "Creando .env desde .env.example..." -ForegroundColor Cyan
            Copy-Item .env.example .env
            Write-Host "✓ Archivo .env creado" -ForegroundColor Green
        } else {
            Write-Host "✗ No se encontró .env.example" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Show-InputFiles {
    $audioFiles = Get-ChildItem -Path "input" -File -ErrorAction SilentlyContinue
    if ($audioFiles.Count -eq 0) {
        Write-Host "⚠ No hay archivos en la carpeta 'input'" -ForegroundColor Yellow
        Write-Host "Coloca tus archivos de audio en 'input' antes de transcribir" -ForegroundColor Gray
        return $false
    } else {
        Write-Host "✓ Archivos encontrados: $($audioFiles.Count)" -ForegroundColor Green
        foreach ($file in $audioFiles | Select-Object -First 5) {
            Write-Host "  • $($file.Name)" -ForegroundColor Gray
        }
        if ($audioFiles.Count -gt 5) {
            Write-Host "  ... y $($audioFiles.Count - 5) archivo(s) más" -ForegroundColor Gray
        }
        return $true
    }
}

function Set-Mode {
    param([string]$Mode)
    
    Write-Host "Configurando MODE=$Mode en .env..." -ForegroundColor Cyan
    
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "MODE=.*", "MODE=$Mode"
    $envContent | Set-Content ".env" -NoNewline
    
    Write-Host "✓ Modo configurado: $Mode" -ForegroundColor Green
}

function Start-Transcription {
    param([string]$Mode)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Iniciando proceso..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Configurar modo
    Set-Mode -Mode $Mode
    
    # Verificar Ollama
    if ($Mode -eq "full" -or $Mode -eq "format-only") {
        Write-Host "Verificando servicio Ollama..." -ForegroundColor Cyan
        docker-compose up -d ollama
        Start-Sleep -Seconds 10
        
        # Verificar modelo
        $modelCheck = docker exec ollama ollama list 2>&1 | Select-String "llama3.2:3b"
        if (-not $modelCheck) {
            Write-Host "⚠ Modelo llama3.2:3b no encontrado" -ForegroundColor Yellow
            Write-Host "Descargando modelo (~2GB)..." -ForegroundColor Yellow
            docker exec ollama ollama pull llama3.2:3b
            Write-Host "✓ Modelo descargado" -ForegroundColor Green
        } else {
            Write-Host "✓ Modelo llama3.2:3b listo" -ForegroundColor Green
        }
    }
    
    # Iniciar proceso
    Write-Host ""
    Write-Host "Iniciando contenedores..." -ForegroundColor Cyan
    docker-compose up -d
    
    Write-Host ""
    Write-Host "✓ Contenedores iniciados" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Para ver logs en tiempo real:" -ForegroundColor Yellow
    Write-Host "   docker logs audio-transcriber --follow" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⏹️  Para detener:" -ForegroundColor Yellow
    Write-Host "   docker-compose down" -ForegroundColor Gray
    Write-Host ""
    
    $viewLogs = Read-Host "¿Ver logs ahora? (s/n)"
    if ($viewLogs -eq "s" -or $viewLogs -eq "S") {
        docker logs audio-transcriber --follow
    }
}

function Show-SystemStatus {
    Show-Banner
    Write-Host "ESTADO DEL SISTEMA" -ForegroundColor Yellow
    Write-Host ""
    
    # Docker
    Write-Host "🐳 Docker:" -ForegroundColor Cyan
    if (Test-Docker) {
        Write-Host "   ✓ Instalado" -ForegroundColor Green
    }
    
    # Contenedores
    Write-Host ""
    Write-Host "📦 Contenedores:" -ForegroundColor Cyan
    $containers = docker ps --filter "name=ollama" --filter "name=audio-transcriber" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    if ($containers.Count -gt 1) {
        $containers | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } else {
        Write-Host "   ⚠ No hay contenedores corriendo" -ForegroundColor Yellow
    }
    
    # Archivos
    Write-Host ""
    Write-Host "📁 Archivos:" -ForegroundColor Cyan
    $inputFiles = (Get-ChildItem -Path "input" -File -ErrorAction SilentlyContinue).Count
    $outputFiles = (Get-ChildItem -Path "output" -File -ErrorAction SilentlyContinue).Count
    Write-Host "   Input:  $inputFiles archivo(s)" -ForegroundColor Gray
    Write-Host "   Output: $outputFiles archivo(s)" -ForegroundColor Gray
    
    # Modelo Ollama
    Write-Host ""
    Write-Host "🤖 Modelo Ollama:" -ForegroundColor Cyan
    $ollamaRunning = docker ps --filter "name=ollama" --format "{{.Names}}"
    if ($ollamaRunning) {
        $modelCheck = docker exec ollama ollama list 2>&1 | Select-String "llama3.2:3b"
        if ($modelCheck) {
            Write-Host "   ✓ llama3.2:3b instalado" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ llama3.2:3b no encontrado" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠ Ollama no está corriendo" -ForegroundColor Yellow
    }
    
    # Configuración
    Write-Host ""
    Write-Host "⚙️  Configuración (.env):" -ForegroundColor Cyan
    if (Test-Path ".env") {
        $mode = (Get-Content ".env" | Select-String "^MODE=").ToString().Split("=")[1]
        $whisperModel = (Get-Content ".env" | Select-String "^WHISPER_MODEL=").ToString().Split("=")[1]
        $dialect = (Get-Content ".env" | Select-String "^AUDIO_DIALECT=").ToString().Split("=")[1]
        Write-Host "   MODE: $mode" -ForegroundColor Gray
        Write-Host "   WHISPER_MODEL: $whisperModel" -ForegroundColor Gray
        Write-Host "   AUDIO_DIALECT: $dialect" -ForegroundColor Gray
    }
    
    Write-Host ""
    Read-Host "Presiona Enter para continuar"
}

function Clear-OutputFiles {
    Show-Banner
    Write-Host "LIMPIAR ARCHIVOS DE SALIDA" -ForegroundColor Yellow
    Write-Host ""
    
    $outputFiles = Get-ChildItem -Path "output" -File -ErrorAction SilentlyContinue
    if ($outputFiles.Count -eq 0) {
        Write-Host "✓ La carpeta 'output' ya está vacía" -ForegroundColor Green
        Start-Sleep -Seconds 2
        return
    }
    
    Write-Host "Se encontraron $($outputFiles.Count) archivo(s) en 'output'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠ ADVERTENCIA: Esta acción eliminará todos los archivos generados" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "¿Estás seguro? (escribe 'si' para confirmar)"
    
    if ($confirm -eq "si" -or $confirm -eq "SI") {
        Remove-Item -Path "output\*" -Force
        Write-Host "✓ Archivos eliminados" -ForegroundColor Green
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 2
}

function Install-FirstTime {
    Show-Banner
    Write-Host "PRIMERA INSTALACIÓN" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Este proceso:" -ForegroundColor Cyan
    Write-Host "  • Verificará Docker" -ForegroundColor Gray
    Write-Host "  • Creará directorios necesarios" -ForegroundColor Gray
    Write-Host "  • Configurará archivo .env" -ForegroundColor Gray
    Write-Host "  • Construirá la imagen Docker (~10-15 min)" -ForegroundColor Gray
    Write-Host "  • Descargará el modelo Ollama (~2GB)" -ForegroundColor Gray
    Write-Host ""
    
    $confirm = Read-Host "¿Continuar? (s/n)"
    if ($confirm -ne "s" -and $confirm -ne "S") {
        return
    }
    
    # Verificar Docker
    Write-Host ""
    if (-not (Test-Docker)) {
        Read-Host "Presiona Enter para salir"
        exit 1
    }
    Write-Host "✓ Docker detectado" -ForegroundColor Green
    
    # Crear directorios
    Write-Host ""
    Initialize-Directories
    
    # Crear .env
    Write-Host ""
    if (-not (Test-EnvFile)) {
        Read-Host "Presiona Enter para salir"
        exit 1
    }
    
    # Construir imagen
    Write-Host ""
    Write-Host "Construyendo imagen Docker..." -ForegroundColor Cyan
    Write-Host "⏱️  Esto puede tardar 10-15 minutos la primera vez" -ForegroundColor Yellow
    Write-Host ""
    docker-compose build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Imagen construida exitosamente" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "✗ Error al construir la imagen" -ForegroundColor Red
        Read-Host "Presiona Enter para continuar"
        return
    }
    
    # Iniciar Ollama y descargar modelo
    Write-Host ""
    Write-Host "Iniciando Ollama y descargando modelo..." -ForegroundColor Cyan
    docker-compose up -d ollama
    Start-Sleep -Seconds 15
    
    Write-Host "Descargando modelo llama3.2:3b (~2GB)..." -ForegroundColor Cyan
    docker exec ollama ollama pull llama3.2:3b
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ INSTALACIÓN COMPLETADA" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ya puedes:" -ForegroundColor Cyan
    Write-Host "  • Colocar archivos de audio en la carpeta 'input'" -ForegroundColor Gray
    Write-Host "  • Usar el menú principal para transcribir" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Presiona Enter para continuar"
}

function Rebuild-Image {
    Show-Banner
    Write-Host "RECONSTRUIR IMAGEN DOCKER" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "¿Usar caché? (más rápido)" -ForegroundColor Cyan
    Write-Host "1. Sí (recomendado)" -ForegroundColor White
    Write-Host "2. No (reconstrucción completa)" -ForegroundColor White
    Write-Host ""
    
    $option = Read-Host "Selecciona (1-2)"
    
    Write-Host ""
    Write-Host "Reconstruyendo imagen..." -ForegroundColor Cyan
    
    if ($option -eq "2") {
        docker-compose build --no-cache
    } else {
        docker-compose build
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Imagen reconstruida" -ForegroundColor Green
    } else {
        Write-Host "✗ Error al reconstruir" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

function Edit-EnvFile {
    if (Test-Path ".env") {
        notepad.exe ".env"
    } else {
        Write-Host "✗ Archivo .env no encontrado" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

function Download-OllamaModel {
    Show-Banner
    Write-Host "DESCARGAR/ACTUALIZAR MODELO OLLAMA" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Iniciando Ollama..." -ForegroundColor Cyan
    docker-compose up -d ollama
    Start-Sleep -Seconds 10
    
    Write-Host "Descargando modelo llama3.2:3b..." -ForegroundColor Cyan
    docker exec ollama ollama pull llama3.2:3b
    
    Write-Host ""
    Write-Host "✓ Modelo actualizado" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Clean-Everything {
    Show-Banner
    Write-Host "LIMPIEZA COMPLETA" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠ ADVERTENCIA: Esto eliminará:" -ForegroundColor Red
    Write-Host "  • Todos los contenedores" -ForegroundColor Gray
    Write-Host "  • Volúmenes de Docker (incluido modelo Ollama)" -ForegroundColor Gray
    Write-Host "  • Redes de Docker" -ForegroundColor Gray
    Write-Host ""
    Write-Host "NO eliminará:" -ForegroundColor Green
    Write-Host "  • Archivos en 'input' y 'output'" -ForegroundColor Gray
    Write-Host "  • La imagen Docker construida" -ForegroundColor Gray
    Write-Host ""
    
    $confirm = Read-Host "¿Estás seguro? (escribe 'si' para confirmar)"
    
    if ($confirm -eq "si" -or $confirm -eq "SI") {
        Write-Host ""
        Write-Host "Deteniendo y eliminando..." -ForegroundColor Cyan
        docker-compose down -v
        Write-Host "✓ Limpieza completa" -ForegroundColor Green
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 2
}

# ============================================================================
# PROGRAMA PRINCIPAL
# ============================================================================

# Verificar Docker al inicio
if (-not (Test-Docker)) {
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Inicializar directorios
Initialize-Directories

# Verificar .env
Test-EnvFile | Out-Null

# Loop del menú principal
do {
    Clear-Host
    Show-MainMenu
    $mainChoice = Read-Host "Selecciona una opción (1-7)"
    
    switch ($mainChoice) {
        "1" {
            Clear-Host
            Show-Banner
            Write-Host "PROCESO COMPLETO: Transcribir + Formatear" -ForegroundColor Yellow
            Write-Host ""
            if (Show-InputFiles) {
                Write-Host ""
                $confirm = Read-Host "¿Iniciar proceso completo? (s/n)"
                if ($confirm -eq "s" -or $confirm -eq "S") {
                    Start-Transcription -Mode "full"
                }
            } else {
                Read-Host "Presiona Enter para continuar"
            }
        }
        "2" {
            Clear-Host
            Show-Banner
            Write-Host "SOLO TRANSCRIBIR (Whisper)" -ForegroundColor Yellow
            Write-Host ""
            if (Show-InputFiles) {
                Write-Host ""
                $confirm = Read-Host "¿Iniciar transcripción? (s/n)"
                if ($confirm -eq "s" -or $confirm -eq "S") {
                    Start-Transcription -Mode "transcribe-only"
                }
            } else {
                Read-Host "Presiona Enter para continuar"
            }
        }
        "3" {
            Clear-Host
            Show-Banner
            Write-Host "SOLO FORMATEAR (Ollama)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "⚠ Requiere transcripciones existentes en 'output'" -ForegroundColor Yellow
            Write-Host ""
            $confirm = Read-Host "¿Iniciar formateo? (s/n)"
            if ($confirm -eq "s" -or $confirm -eq "S") {
                Start-Transcription -Mode "format-only"
            }
        }
        "4" {
            do {
                Clear-Host
                Show-ConfigMenu
                $configChoice = Read-Host "Selecciona una opción (1-6)"
                
                switch ($configChoice) {
                    "1" { Install-FirstTime }
                    "2" { Rebuild-Image }
                    "3" { Edit-EnvFile }
                    "4" { Download-OllamaModel }
                    "5" { Clean-Everything }
                    "6" { break }
                }
            } while ($configChoice -ne "6")
        }
        "5" {
            Clear-Host
            Show-SystemStatus
        }
        "6" {
            Clear-Host
            Clear-OutputFiles
        }
        "7" {
            Clear-Host
            Show-Banner
            Write-Host "¡Hasta pronto! 👋" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
        default {
            Write-Host "Opción inválida" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)



