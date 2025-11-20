# 🎯 RESUMEN DEL PROYECTO

## ¿Qué hace este sistema?

Este sistema es una **solución Docker 100% local** que:

1. **Transcribe archivos de audio** de larga duración usando Whisper de OpenAI
2. **Formatea automáticamente** las transcripciones usando **Ollama (100% local y gratuito)**
3. **Genera análisis avanzado** (resúmenes, puntos clave, temas principales)
4. **Procesa múltiples archivos** en lote
5. **Funciona completamente offline** - No requiere internet después de la instalación inicial

## 📦 Estructura del Proyecto Creado

```
d:\PRUEBA CREAR TRANSCRIPCION\
│
├── 📄 Dockerfile                    # Configuración de la imagen Docker
├── 📄 docker-compose.yml            # Orquestación de servicios (Ollama + Transcriptor)
├── 📄 requirements.txt              # Dependencias Python
├── 📄 .env.example                  # Plantilla de configuración
├── 📄 .env                          # Tu configuración (creado automáticamente)
├── 📄 .gitignore                    # Archivos a ignorar en Git
├── 📄 .dockerignore                 # Archivos a ignorar en Docker
│
├── 📁 src/                          # Código fuente
│   ├── main.py                      # Orquestador principal
│   ├── transcribe.py                # Motor de transcripción (Whisper)
│   ├── format_ollama.py             # Motor de formateo (Ollama - LOCAL)
│   └── format_gemini.py             # Motor de formateo alternativo (Gemini - requiere API)
│
├── 📁 input/                        # COLOCA TUS ARCHIVOS DE AUDIO AQUÍ
│   └── README.md
│
├── 📁 output/                       # AQUÍ APARECEN LAS TRANSCRIPCIONES
│   └── README.md                    # 6 archivos por audio (transcripción + análisis)
│
├── 📁 logs/                         # Logs de ejecución
│   └── README.md
│
├── 📜 run.ps1                       # Script principal de ejecución
├── 📜 clean.ps1                     # Script de limpieza
├── 📜 verify.ps1                    # Script de verificación
│
├── 📖 README.md                     # Documentación completa
├── 📖 QUICKSTART.md                 # Guía de inicio rápido
└── 📖 PROYECTO.md                   # Este archivo
```

## 🔄 Evolución del Proyecto

| Aspecto | Versión Inicial (Gemini) | Versión Actual (Ollama) |
|---------|--------------------------|-------------------------|
| **Formateo** | Google Gemini (requiere API key) | Ollama local (100% gratuito) |
| **Internet** | Necesario para formateo | Solo instalación inicial |
| **Costo** | $$ por llamadas API | Completamente gratis |
| **Privacidad** | Datos enviados a Google | Todo local en tu PC |
| **Análisis** | Solo formateo básico | Resúmenes + Puntos clave + Temas |
| **Configuración** | Manual compleja | Automática (run.ps1) |
| **Modelos** | Limitado a Gemini | Múltiples modelos Ollama |
| **GPU** | Soporte básico | Optimizado para GPUs 6GB+ |

## 🚀 Pasos para Empezar

### 1. Instalar Docker (solo primera vez)

**Docker no está instalado en tu sistema.** Descárgalo aquí:

👉 **Windows**: https://www.docker.com/products/docker-desktop

**Pasos de instalación:**
1. Descarga Docker Desktop para Windows
2. Ejecuta el instalador
3. Reinicia tu PC si es necesario
4. Abre Docker Desktop y espera que inicie completamente
5. Verifica la instalación ejecutando:
   ```powershell
   docker --version
   docker-compose --version
   ```

### 2. Configurar el Proyecto

```powershell
# La configuración está lista para usar con valores óptimos

# Opcional: Editar configuración avanzada
notepad .env

# NO necesitas API Keys - Todo es local con Ollama
# El script run.ps1 descargará automáticamente el modelo llama3.2:3b (~2GB)
```

### 3. Agregar Archivos de Audio

```powershell
# Copiar tus archivos de audio a la carpeta input
Copy-Item "C:\ruta\a\tu\audio.mp3" input\

# O múltiples archivos
Copy-Item "C:\ruta\a\tus\audios\*.m4a" input\
```

### 4. Ejecutar

```powershell
# Opción 1: Usar el script automático (recomendado)
.\run.ps1

# Opción 2: Manualmente
docker-compose build
docker-compose up
```

### 5. Ver Resultados

Los archivos procesados aparecerán en `output/` (6 archivos por audio):

**Transcripciones básicas (Whisper):**
- `*_transcripcion.txt` - Texto limpio sin timestamps
- `*_transcripcion_detallada.txt` - Con timestamps [MM:SS.000]

**Análisis avanzado (Ollama):**
- `*_transcripcion_formateada.txt` - Texto estructurado con párrafos
- `*_resumen.txt` - Resumen ejecutivo de 3-5 párrafos
- `*_puntos_clave.txt` - Lista de conceptos importantes
- `*_temas.txt` - Temas principales identificados

## 🎛️ Configuración Recomendada

En el archivo `.env`:

```env
# Configuración base (ya incluida)
MODE=full                    # Transcribir + Formatear + Analizar
FORMATTER=ollama             # Motor de formateo (100% local)
AUDIO_LANGUAGE=es            # Idioma del audio

# Modelo Whisper según tu GPU
WHISPER_MODEL=small          # Para GPUs 6GB (RTX 2060, 1060 6GB)
# WHISPER_MODEL=medium       # Para GPUs 8GB+ (RTX 3060, 2070)
# WHISPER_MODEL=large        # Para GPUs 12GB+ (RTX 3080, 4070)

# Límite de memoria GPU
GPU_MEMORY_LIMIT=2048        # 2GB para modelo small
# GPU_MEMORY_LIMIT=4096      # 4GB para modelo medium

# Modelo Ollama (se descarga automáticamente)
OLLAMA_MODEL=llama3.2:3b     # Ligero y rápido (~2GB)

# Análisis avanzado (activado por defecto)
ENABLE_SUMMARY=true          # Resumen ejecutivo
ENABLE_KEY_POINTS=true       # Puntos clave
ENABLE_TOPICS=true           # Temas principales
```

## 💡 Ventajas de esta Solución

✅ **100% Local** - No envía tus datos a ningún servidor
✅ **100% Gratuito** - No requiere API keys ni suscripciones
✅ **Sin Internet** - Funciona offline después de instalación inicial
✅ **Procesamiento en lote** - Múltiples archivos automáticamente
✅ **Análisis avanzado** - Resúmenes, puntos clave, temas automáticos
✅ **Configuración automática** - El script run.ps1 descarga todo lo necesario
✅ **Optimizado para GPU** - Configuraciones preestablecidas para GPUs comunes
✅ **Repetible** - Mismos resultados siempre
✅ **Portable** - Comparte el proyecto fácilmente
✅ **Logs completos** - Debugging más fácil

## 📊 Recursos Necesarios

### Modelos Whisper (Transcripción)

| Modelo | VRAM GPU | Tiempo (1h audio) | Calidad | GPU Recomendada |
|--------|----------|-------------------|---------|-----------------|
| tiny   | ~1 GB    | ~3 min            | Básica  | Cualquiera      |
| base   | ~1 GB    | ~5 min            | Aceptable | Cualquiera    |
| **small** | **~2 GB** | **~8 min**     | **Buena** | **RTX 2060 6GB** ✅ |
| medium | ~5 GB    | ~15 min           | Excelente | RTX 3060 12GB  |
| large  | ~10 GB   | ~30 min           | Máxima  | RTX 3080 12GB   |

### Modelos Ollama (Formateo y Análisis)

| Modelo | Tamaño | VRAM | Velocidad | Calidad |
|--------|--------|------|-----------|---------|
| **llama3.2:3b** | **2 GB** | **~600 MB** | **Rápida** | **Excelente** ✅ |
| llama3.2:1b | 1 GB | ~400 MB | Muy rápida | Buena |
| llama3:8b | 4.5 GB | ~2 GB | Media | Superior |
| mistral | 4 GB | ~1.5 GB | Media | Excelente |

### Configuración Óptima para GPUs 6GB (RTX 2060)

```env
WHISPER_MODEL=small           # 2GB VRAM
GPU_MEMORY_LIMIT=2048         # Límite seguro
OLLAMA_MODEL=llama3.2:3b      # 600MB VRAM
```

**Total usado:** ~0.9GB Whisper + ~0.6GB Ollama = **~1.5GB** (25% de 6GB) ✅

## ❓ FAQ

**P: ¿Necesito internet?**
R: Solo para la instalación inicial (descargar Docker, modelos Whisper y Ollama). Después funciona 100% offline.

**P: ¿Necesito una API key de Google/OpenAI?**
R: NO. Todo funciona localmente con Ollama. Es 100% gratuito.

**P: ¿Se envían mis audios a algún servidor?**
R: NO. Todo el procesamiento es local en tu PC. Privacidad total.

**P: ¿Funciona con GPU?**
R: Sí, automáticamente detecta y usa GPU NVIDIA si está disponible. Configuraciones preestablecidas para GPUs 6GB, 8GB y 12GB.

**P: ¿El script run.ps1 descarga todo automáticamente?**
R: Sí, verifica e instala el modelo llama3.2:3b si no existe (~2GB). Primera ejecución puede tardar 5-10 minutos.

**P: ¿Puedo transcribir sin análisis/formateo?**
R: Sí, cambia `MODE=transcribe-only` en `.env`.

**P: ¿Puedo desactivar solo algunos análisis?**
R: Sí, en `.env` configura:
```env
ENABLE_SUMMARY=false      # Desactivar resumen
ENABLE_KEY_POINTS=true    # Mantener puntos clave
ENABLE_TOPICS=true        # Mantener temas
```

**P: ¿Cuánto tarda?**
R: Con `small` + `llama3.2:3b`, aproximadamente **10-15 minutos por hora de audio** (transcripción + análisis completo).

**P: ¿Qué formatos de audio acepta?**
R: MP3, WAV, M4A, FLAC, AAC, OGG, WMA, OPUS, MP4 (audio) y más.

**P: ¿Puedo usar modelos más potentes?**
R: Sí, edita en `.env`:
- `WHISPER_MODEL=medium` o `large` (requiere más VRAM)
- `OLLAMA_MODEL=llama3:8b` o `mistral` (mejor calidad, más lento)

## 🔧 Comandos Útiles

```powershell
# Verificar que todo está listo
.\verify.ps1

# Ejecutar el sistema
.\run.ps1

# Limpiar todo
.\clean.ps1

# Ver logs en tiempo real
docker-compose logs -f

# Detener el contenedor
docker-compose down

# Reconstruir la imagen
docker-compose build --no-cache
```

## 📞 Soporte

Si tienes problemas:

1. Ejecuta `.\verify.ps1` para diagnosticar
2. Revisa los logs en `logs/`
3. Consulta el `README.md` completo
4. Revisa que Docker esté corriendo

## 🎉 ¡Listo para usar!

Una vez que instales Docker:

```powershell
.\verify.ps1      # Verifica que todo esté bien
.\run.ps1         # Ejecuta el sistema
```

## 🔧 Problemas Resueltos en Versiones Recientes

### ✅ Versión 1.3 (Noviembre 2025)

**Problema 1:** Modelo Ollama no se descargaba automáticamente
- ✅ **Solución:** `run.ps1` ahora verifica y descarga `llama3.2:3b` automáticamente

**Problema 2:** Docker mostraba Ollama como "unhealthy" aunque funcionaba
- ✅ **Solución:** Eliminado healthcheck problemático de `docker-compose.yml`

**Problema 3:** Variables de análisis (ENABLE_*) no se pasaban al contenedor
- ✅ **Solución:** Agregadas al `.env` y `docker-compose.yml`

**Problema 4:** GPU Out of Memory con RTX 2060 6GB
- ✅ **Solución:** Configuraciones optimizadas para GPUs comunes (small + 2GB límite)

### 📦 Commits Importantes

- `383818e` - Variables ENABLE_* para control de análisis
- `de2f1c6` - Eliminación de healthcheck problemático
- `7bb7f72` - Descarga automática del modelo Ollama
- `ba4b189` - Sistema de análisis avanzado con Ollama

---

**Solución profesional 100% local y gratuita**  
De transcripción básica a análisis completo con IA local.
