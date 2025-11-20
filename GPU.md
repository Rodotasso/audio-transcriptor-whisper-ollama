# 🎮 GUÍA DE USO DE GPU NVIDIA

## 🎯 Resumen

El sistema ahora **detecta y usa automáticamente tu GPU NVIDIA** si está disponible, con **límite configurable de VRAM**.

---

## ✅ Configuración Predeterminada

```env
USE_GPU=auto           # Detección automática
GPU_MEMORY_LIMIT=2048  # Límite de 2GB de VRAM
```

### ¿Qué hace esto?

- ✅ **Detecta automáticamente** si tienes GPU NVIDIA con CUDA
- ✅ **Usa solo 2GB de VRAM** (deja espacio para otras aplicaciones)
- ✅ **Falla gracefully** a CPU si hay problemas
- ✅ **Funciona sin configuración** adicional

---

## 🛠️ Configuraciones Comunes

### Caso 1: Tengo GPU Potente (6GB+ VRAM)

```env
USE_GPU=auto
GPU_MEMORY_LIMIT=4096  # Usar 4GB
WHISPER_MODEL=large    # Modelo más preciso
```

### Caso 2: GPU Compartida (Gaming + Transcripción)

```env
USE_GPU=auto
GPU_MEMORY_LIMIT=2048  # Solo 2GB, deja resto libre
WHISPER_MODEL=medium
```

### Caso 3: Solo Tengo CPU (Sin GPU)

```env
USE_GPU=false          # Forzar CPU
WHISPER_MODEL=small    # Modelo más ligero
```

### Caso 4: GPU de Laptop (4GB VRAM)

```env
USE_GPU=auto
GPU_MEMORY_LIMIT=3072  # Usar 3GB
WHISPER_MODEL=medium
```

### Caso 5: Quiero Usar Toda la GPU

```env
USE_GPU=auto
GPU_MEMORY_LIMIT=8192  # 8GB (ajusta según tu GPU)
WHISPER_MODEL=large
```

---

## 📊 Uso de VRAM por Modelo Whisper

| Modelo | VRAM Necesaria | GPU_MEMORY_LIMIT Recomendado |
|--------|----------------|------------------------------|
| tiny | ~500 MB | 1024 (1GB) |
| base | ~750 MB | 1024 (1GB) |
| small | ~1.5 GB | 2048 (2GB) |
| **medium** | **~2.5 GB** | **2048-3072 (2-3GB)** |
| large | ~5 GB | 6144 (6GB) |

---

## 🚀 Verificar si Está Usando GPU

Cuando ejecutes `.\run.ps1`, verás en los logs:

### ✅ GPU Detectada y Funcionando

```
🎮 GPU detectada: NVIDIA GeForce RTX 3060
📊 VRAM total disponible: 12.00 GB
⚙️  Límite configurado: 2048 MB (2.00 GB)
✅ Límite de VRAM aplicado: 2048MB = 16.7% de GPU
Dispositivo seleccionado: cuda
Cargando modelo Whisper (medium)...
✅ Modelo cargado en GPU
📊 VRAM utilizada: 2.13 GB (reservada: 2.25 GB)
```

### 🖥️ Usando CPU

```
🖥️  GPU NVIDIA no detectada. Usando CPU.
Dispositivo seleccionado: cpu
Cargando modelo Whisper (medium)...
✅ Modelo cargado en CPU
```

---

## ⚠️ Solución de Problemas

### Error: "CUDA out of memory"

**Causa:** GPU sin suficiente VRAM libre.

**Soluciones:**
```env
# Opción 1: Aumentar límite (si tu GPU tiene más VRAM)
GPU_MEMORY_LIMIT=4096

# Opción 2: Usar modelo más pequeño
WHISPER_MODEL=small
GPU_MEMORY_LIMIT=1024

# Opción 3: Forzar uso de CPU
USE_GPU=false
```

### GPU No Detectada (Teniendo NVIDIA)

**Verificar Docker con GPU:**
```powershell
# Ver si Docker detecta tu GPU
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

**Si falla:**
1. Instalar [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
2. Reiniciar Docker Desktop
3. Verificar en Docker Desktop → Settings → Resources → GPU

### Sistema Lento con GPU

**Posibles causas:**
- Límite de VRAM muy bajo (GPU hace swap)
- Modelo muy grande para tu GPU

**Solución:**
```env
# Aumentar límite o usar CPU
GPU_MEMORY_LIMIT=3072  # Intentar con 3GB
# O
USE_GPU=false  # Usar CPU si es más rápido
```

---

## 🔍 Comandos Útiles

### Ver Uso de GPU en Tiempo Real

```powershell
# Abrir otro terminal y ejecutar:
docker exec -it audio-transcriber nvidia-smi

# Refrescar cada 2 segundos
docker exec -it audio-transcriber watch -n 2 nvidia-smi
```

### Ver Logs Detallados

```powershell
docker-compose logs -f audio-transcriber | Select-String "GPU|VRAM|cuda"
```

---

## 🎯 Recomendaciones

### Para Máxima Velocidad
```env
USE_GPU=auto
GPU_MEMORY_LIMIT=4096  # 4GB
WHISPER_MODEL=medium   # Balance velocidad/calidad
```

### Para Máxima Calidad
```env
USE_GPU=auto
GPU_MEMORY_LIMIT=6144  # 6GB
WHISPER_MODEL=large    # Mejor precisión
```

### Para Uso Conservador
```env
USE_GPU=auto
GPU_MEMORY_LIMIT=2048  # Solo 2GB
WHISPER_MODEL=medium   # Buena calidad
```

### Para Laptops
```env
USE_GPU=auto
GPU_MEMORY_LIMIT=2048  # Conservador
WHISPER_MODEL=small    # Evita sobrecalentamiento
```

---

## 🔧 Configuración Avanzada

### Usar GPU Específica (Multi-GPU)

Edita `docker-compose.yml`:
```yaml
environment:
  - CUDA_VISIBLE_DEVICES=0  # GPU 0, 1, 2, etc.
```

### Monitorear Temperatura GPU

```powershell
# Requiere nvidia-smi
docker exec -it audio-transcriber nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
```

---

## ✅ Checklist de GPU

Verifica que todo funciona:

- [ ] Docker Desktop tiene acceso a GPU habilitado
- [ ] `USE_GPU=auto` en `.env`
- [ ] `GPU_MEMORY_LIMIT` configurado según tu GPU
- [ ] Logs muestran "GPU detectada" al ejecutar
- [ ] VRAM utilizada está dentro del límite
- [ ] Transcripción es más rápida que con CPU

---

## 📚 Recursos

- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)
- [Docker GPU Support](https://docs.docker.com/config/containers/resource_constraints/#gpu)
- [Whisper GPU Requirements](https://github.com/openai/whisper#available-models-and-languages)

---

**Última actualización:** 19 de noviembre de 2025  
**Versión:** 1.0.0
