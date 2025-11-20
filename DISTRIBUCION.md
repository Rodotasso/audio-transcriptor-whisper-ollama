# 📦 GUÍA DE DISTRIBUCIÓN Y REPRODUCIBILIDAD

## Objetivo

Hacer que el sistema sea **100% reproducible** en cualquier computador sin necesidad de descargar modelos o configurar APIs externas.

---

## 🎯 Tres Métodos de Distribución

### Método 1: Código + Descarga Automática (Más Liviano)

**Tamaño:** ~50 MB  
**Ventajas:** Paquete pequeño, fácil de compartir  
**Desventajas:** Requiere internet en primera ejecución (descarga ~4-5GB de modelos)

#### Pasos:

1. **Empaquetar:**
   ```powershell
   # Copiar solo el código y configuración
   $files = @(
       "docker-compose.yml", "Dockerfile", "requirements.txt",
       ".env.example", "*.md", "*.ps1", "src"
   )
   Compress-Archive -Path $files -DestinationPath "transcriptor-lite.zip"
   ```

2. **Distribuir:** Compartir `transcriptor-lite.zip`

3. **Instalar en nuevo computador:**
   ```powershell
   Expand-Archive transcriptor-lite.zip
   cd transcriptor-lite
   Copy-Item .env.example .env
   .\run.ps1  # Descarga modelos automáticamente
   ```

---

### Método 2: Instalación Desde GitHub (Recomendado)

**Tamaño:** ~50 MB (código) + ~6 GB (descarga automática)  
**Ventajas:** Siempre actualizado, menú interactivo guía instalación  
**Desventajas:** Requiere internet en primera ejecución

#### Pasos:

1. **Clonar repositorio:**
   ```powershell
   git clone https://github.com/Rodotasso/audio-transcriptor-whisper-ollama.git
   cd audio-transcriptor-whisper-ollama
   ```

2. **Ejecutar menú interactivo:**
   ```powershell
   .\run.ps1
   ```

3. **Seleccionar opción 4 (Configuración) → Opción 1 (Primera instalación)**
   - El menú construye imagen Docker automáticamente (~4GB Whisper)
   - Descarga modelo Ollama (~2GB) en primer uso
   - Configura directorios y variables

4. **Listo para usar:**
   - Colocar audios en `input/`
   - Ejecutar `.\run.ps1` → Opción 1 (Proceso completo)
   - Resultados en `output/`

---

### Método 3: Paquete Completo con Modelos (100% Offline)

**Tamaño:** ~10-12 GB  
**Ventajas:** Completamente autónomo, no requiere internet nunca  
**Desventajas:** Archivo muy grande, difícil de compartir

#### Pasos:

1. **Ejecutar el sistema una vez** para descargar todos los modelos:
   ```powershell
   .\run.ps1
   # Esperar a que descargue modelos de Ollama
   ```

2. **Construir paquete con imágenes:**
   ```powershell
   .\build-package.ps1 -ExportImages
   ```

3. **Exportar volúmenes con modelos:**
   ```powershell
   .\volume-manager.ps1 -Action export -BackupDir ".\package\volumes"
   ```

4. **Comprimir todo:**
   ```powershell
   Compress-Archive -Path ".\package\*" -DestinationPath "transcriptor-offline.zip"
   ```

5. **Instalar en nuevo computador (100% offline):**
   ```powershell
   # Sin conexión a internet
   Expand-Archive transcriptor-offline.zip
   cd transcriptor-offline
   
   # Cargar imágenes Docker
   docker load -i audio-transcriber.tar
   docker load -i ollama.tar
   
   # Restaurar modelos
   .\volume-manager.ps1 -Action import -BackupDir ".\volumes"
   
   # Configurar y ejecutar
   Copy-Item .env.example .env
   .\run.ps1  # Funciona inmediatamente
   ```

---

## 📊 Comparación de Métodos

| Método | Tamaño | Internet 1ra vez | Internet después | Setup |
|--------|--------|------------------|------------------|-------|
| **1. Lite** | ~50 MB | ✅ Requerido (~5GB) | ❌ No | Muy simple |
| **2. Full** | ~8 GB | ⚠️ Parcial (~2GB) | ❌ No | Simple |
| **3. Offline** | ~12 GB | ❌ No | ❌ No | Medio |

---

## 🚀 Recomendaciones por Caso de Uso

### Para Desarrollo/Pruebas
👉 **Método 1 (Lite)**
- Rápido de compartir entre equipo
- Cada desarrollador descarga modelos una vez

### Para Producción/Demostración
👉 **Método 2 (Full)**
- Balance entre tamaño y conveniencia
- Primera ejecución rápida (solo Ollama)

### Para Ambientes Restringidos (Sin Internet)
👉 **Método 3 (Offline)**
- Servidores aislados
- Ambientes de alta seguridad
- Computadores sin conexión

---

## 🔧 Personalización de Modelos

### Cambiar Modelos Whisper Incluidos

Edita `Dockerfile` (líneas 18-22):

```dockerfile
# Incluir solo los modelos que necesitas:
RUN python -c "import whisper; whisper.load_model('tiny')"    # ~70MB
RUN python -c "import whisper; whisper.load_model('base')"    # ~140MB
RUN python -c "import whisper; whisper.load_model('small')"   # ~460MB
RUN python -c "import whisper; whisper.load_model('medium')"  # ~1.5GB
# RUN python -c "import whisper; whisper.load_model('large')" # ~3GB
```

**Recomendación:** Incluye solo `medium` para reducir tamaño de imagen (~4GB en vez de ~6GB).

### Cambiar Modelo Ollama

Edita `.env`:

```env
# Modelos disponibles:
OLLAMA_MODEL=llama3.2:1b    # ~1GB - Más liviano
OLLAMA_MODEL=llama3.2:3b    # ~2GB - Recomendado
OLLAMA_MODEL=llama3:8b      # ~4.5GB - Más calidad
OLLAMA_MODEL=mistral:7b     # ~4GB - Alternativa
```

---

## 📝 Checklist de Distribución

Antes de compartir, verifica:

- [ ] Archivo `.env.example` actualizado con valores por defecto
- [ ] `README.md` con instrucciones claras
- [ ] Scripts `.ps1` con permisos de ejecución
- [ ] Directorios `input/`, `output/`, `logs/` creados
- [ ] Archivo `INSTALL.md` incluido (lo crea `build-package.ps1`)
- [ ] Probado en computador limpio (sin Docker previo)

---

## ⚙️ Automatización Completa

Script todo-en-uno para construcción y distribución:

```powershell
# Construir paquete completo offline
.\build-package.ps1 -ExportImages -IncludeLarge
.\volume-manager.ps1 -Action export -BackupDir ".\package\volumes"
Compress-Archive -Path ".\package\*" -DestinationPath "transcriptor-v1.0.zip" -Force

Write-Host "✅ Paquete listo para distribución: transcriptor-v1.0.zip"
```

---

## 🐛 Solución de Problemas

### "docker load" falla
```powershell
# Verificar integridad del archivo
Get-FileHash audio-transcriber.tar -Algorithm SHA256

# Re-exportar con compresión
docker save transcripcion-audio-transcriber:latest | gzip > audio-transcriber.tar.gz
```

### Modelos no se cargan después de importar
```powershell
# Verificar volumen
docker volume inspect transcripcion_ollama-data

# Listar contenido
docker run --rm -v transcripcion_ollama-data:/data alpine ls -lah /data
```

### Imagen muy grande
```powershell
# Limpiar capas innecesarias
docker image prune -a

# Ver tamaño por capa
docker history transcripcion-audio-transcriber:latest
```

---

## 📚 Recursos Adicionales

- **Dockerfile:** Configuración de imagen base
- **docker-compose.yml:** Orquestación de servicios
- **build-package.ps1:** Script de empaquetado
- **volume-manager.ps1:** Gestión de volúmenes
- **run.ps1:** Ejecución principal

---

## 🔄 Actualizaciones

Para actualizar un paquete distribuido:

1. Mantener volúmenes existentes (conserva modelos)
2. Actualizar solo código: `docker-compose build --no-cache`
3. Re-exportar si cambió la estructura

---

## ✅ Validación de Paquete

Script de verificación post-instalación:

```powershell
# Verificar que todo está en orden
.\verify.ps1

# Probar transcripción rápida
# Coloca audio corto en input/
docker-compose run --rm audio-transcriber python src/main.py
```

---

**Última actualización:** 19 de noviembre de 2025  
**Versión:** 1.0.0
