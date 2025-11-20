# 🎤 Sistema de Transcripción y Formateo de Audio

Sistema completo basado en Docker para **transcribir y formatear archivos de audio de larga duración** usando Whisper (transcripción) y Ollama (formateo local con LLM).

## Características

- **100% Local y Gratuito** - Sin APIs de pago ni conexión a internet (después de setup inicial)
- **Dockerizado** - Funciona en cualquier computador con Docker
- **Reproducible** - Clone y ejecute en minutos
- **Inteligente** - Salta archivos ya transcritos automáticamente
- **Formateo Profesional** - Usa LLM local (Ollama) para limpiar y estructurar el texto
- **Análisis Automático** - Genera resúmenes, puntos clave y temas principales
- **Multiidioma** - Soporta español, inglés y más de 90 idiomas
- **Totalmente Configurable** - Activa/desactiva cada función según necesites

## 🚀 Inicio Rápido

> **¿Qué se descarga en la primera ejecución?**
> 
> En la **primera vez que ejecutes** el sistema, Docker descargará automáticamente:
> - Modelos de IA de Whisper (~1-5GB según tu configuración)
> - Modelo de Ollama LLM (~2GB)
> - Imágenes Docker base (~1GB)
> 
> **Total: ~5-7GB | Tiempo estimado: 15-30 minutos**
> 
> **Esto solo ocurre una vez.** Después, todo funciona offline y de forma instantánea.

### Requisitos Previos

> **NOTA:** Este sistema requiere Docker Desktop y NO funciona en móviles (Android/iOS).

- **Windows 10/11** (con PowerShell) o Mac/Linux
- **[Docker Desktop](https://www.docker.com/products/docker-desktop)** instalado → [¿Cómo instalar?](#instalación-de-docker)
- **8GB RAM** mínimo (16GB recomendado)
- **10GB espacio** en disco libre (para modelos)

> **¿Y si no tengo GPU o no sé si tengo una?**
> 
> **¡No te preocupes! El sistema funciona perfectamente sin GPU.**
> 
> - ✅ **Detección automática:** El sistema detecta automáticamente si tienes GPU NVIDIA
> - ✅ **Funciona sin GPU:** Usa tu CPU (procesador normal) si no hay GPU
> - ✅ **Mismo resultado:** La calidad de transcripción es idéntica, solo tarda un poco más
> - ⏱️ **Diferencia de tiempo:** Con GPU: ~15 min por hora de audio | Sin GPU: ~30-40 min
> - 🔧 **Configuración automática:** No necesitas tocar nada, funciona al ejecutar `.\run.ps1`
> 
> **En resumen:** Funciona en cualquier PC moderna. Si tienes GPU se usará automáticamente (más rápido), si no, usará CPU (un poco más lento pero igual de confiable).

### Instalación en 3 Pasos

```powershell
# 1. Clonar repositorio (o descargar ZIP desde GitHub)
git clone https://github.com/TU_USUARIO/NOMBRE_REPO.git
cd NOMBRE_REPO

# 2. Configurar (copia la plantilla de configuración)
Copy-Item .env.example .env

# 3. Ejecutar (¡ya está!)
.\run.ps1
```

**¡Listo!** El sistema descargará los modelos automáticamente en la primera ejecución.

> **Primera ejecución:** El script `run.ps1` descargará automáticamente:
> - Modelos de Whisper (~1-5GB según configuración)
> - Modelo Ollama llama3.2:3b (~2GB) - **se descarga automáticamente al ejecutar run.ps1**
> - **Total: ~5-7GB | Tiempo: 15-30 minutos**
> - Solo se descarga una vez, después es instantáneo

> **IMPORTANTE:** El script `run.ps1` verificará si el modelo de Ollama está descargado y lo instalará automáticamente si no existe. **No necesitas hacer nada manualmente.**

> **¿Primera vez con Docker?** Ve a la [Guía de Inicio Rápido](QUICKSTART.md) con explicaciones paso a paso.

## Instalación de Docker

Si **no tienes Docker instalado**, sigue estos pasos:

1. **Descargar:** Ve a https://www.docker.com/products/docker-desktop
2. **Instalar:** Ejecuta el instalador y sigue las instrucciones
3. **Reiniciar:** Reinicia tu computador cuando termine
4. **Verificar:** Abre Docker Desktop y espera a que diga "Docker is running"

> **Windows Home:** Docker Desktop requiere WSL2. El instalador lo configurará automáticamente.

### ¿Funciona en móviles?

**No.** Este sistema requiere:
- Docker Desktop (no disponible en Android/iOS)
- Procesamiento intensivo (modelos de IA de varios GB)
- Mínimo 8GB RAM

**Alternativas para móviles:**
- Usa servicios en línea como Google Speech-to-Text, Otter.ai, o Rev
- Transfiere el audio a tu PC y usa este sistema
- Usa apps móviles específicas como Transcribe, Rev Voice Recorder

---

## Uso

### Transcribir Audio

1. Coloca archivos de audio (`.mp3`, `.m4a`, `.wav`, etc.) en la carpeta `input/`
2. Ejecuta `.\run.ps1` en PowerShell
3. Encuentra las transcripciones en `output/`

### Ejemplo Completo

```powershell
# Estructura antes
input/
├── entrevista.m4a
└── conferencia.mp3

# Ejecutar
.\run.ps1

# Estructura después (con análisis completo habilitado)
output/
├── entrevista_transcripcion.txt               # Transcripción limpia
├── entrevista_transcripcion_detallada.txt     # Con timestamps
├── entrevista_transcripcion_formateada.txt    # Formateado con LLM
├── entrevista_resumen.txt                     # Resumen ejecutivo
├── entrevista_puntos_clave.txt                # Puntos importantes
├── entrevista_temas.txt                       # Temas principales
├── conferencia_transcripcion.txt
├── conferencia_transcripcion_detallada.txt
├── conferencia_transcripcion_formateada.txt
├── conferencia_resumen.txt                    # Resumen ejecutivo
├── conferencia_puntos_clave.txt               # Puntos importantes
└── conferencia_temas.txt                      # Temas principales
```

### Archivos Generados por Audio

Por cada archivo de audio, el sistema genera **hasta 6 archivos de salida**:

| Archivo | Descripción | Siempre se genera |
|---------|-------------|-------------------|
| `*_transcripcion.txt` | Texto limpio sin timestamps | Sí |
| `*_transcripcion_detallada.txt` | Con timestamps de Whisper | Sí |
| `*_transcripcion_formateada.txt` | Formateado y estructurado con LLM | Sí (si FORMATTER activo) |
| `*_resumen.txt` | Resumen ejecutivo de 3-5 párrafos | Configurable (`ENABLE_SUMMARY`) |
| `*_puntos_clave.txt` | Lista de puntos más importantes | Configurable (`ENABLE_KEY_POINTS`) |
| `*_temas.txt` | Temas principales discutidos | Configurable (`ENABLE_TOPICS`) |

## Configuración

Edita el archivo `.env` para personalizar:

```env
# Modelo de Whisper (velocidad vs calidad)
WHISPER_MODEL=medium  # tiny, base, small, medium, large

# Idioma del audio
AUDIO_LANGUAGE=es     # es, en, fr, etc.

# Motor de formateo
FORMATTER=ollama      # ollama (local) o gemini (API)

# Modelo de Ollama
OLLAMA_MODEL=llama3.2:3b  # llama3.2:1b, llama3:8b, mistral

# Análisis avanzado (generar resúmenes y análisis automáticamente)
ENABLE_SUMMARY=true      # Resumen ejecutivo
ENABLE_KEY_POINTS=true   # Puntos clave
ENABLE_TOPICS=true       # Temas principales
```

### Configurar Análisis Avanzado

El sistema puede generar **automáticamente** análisis adicionales de cada transcripción. Controla qué se genera:

```env
# ¿Quieres solo la transcripción básica? Desactiva todo
ENABLE_SUMMARY=false
ENABLE_KEY_POINTS=false
ENABLE_TOPICS=false

# ¿Quieres análisis completo? Activa todo (recomendado)
ENABLE_SUMMARY=true      # Genera resumen ejecutivo de 3-5 párrafos
ENABLE_KEY_POINTS=true   # Extrae los puntos más importantes (lista)
ENABLE_TOPICS=true       # Identifica temas principales discutidos

# ¿Solo resumen? Activa solo lo que necesites
ENABLE_SUMMARY=true
ENABLE_KEY_POINTS=false
ENABLE_TOPICS=false
```

**Tiempo adicional:** Cada análisis toma ~2-5 minutos extra por audio (dependiendo de duración).

### ⏱️ Tiempos de Procesamiento (Audio de 1 hora)

> **¿No sabes si tienes GPU?** No importa, el sistema funciona igual. Con GPU será más rápido, sin GPU tardará un poco más.

#### Transcripción con Whisper

| Modelo Whisper | Con GPU NVIDIA | Sin GPU (CPU) | Precisión | Uso Recomendado |
|----------------|----------------|---------------|-----------|-----------------|
| tiny | 2-3 min | 5-8 min | Básica | Pruebas rápidas |
| base | 3-5 min | 8-12 min | Buena | Audio claro |
| **small** | **5-10 min** | **15-25 min** | **Muy buena** | **Recomendado sin GPU** ✅ |
| **medium** | **10-20 min** | **30-50 min** | **Excelente** | **Recomendado con GPU** ✅ |
| large | 20-40 min | 60-120 min | Máxima | Producción profesional |

#### Análisis con Ollama (adicional, igual con/sin GPU)

- Formateo: ~2-3 min por audio
- Resumen: ~3-5 min por audio
- Puntos clave: ~2-4 min por audio
- Temas: ~1-2 min por audio

**Tiempo total estimado (medium + análisis completo):**
- 🚀 **Con GPU NVIDIA:** 18-34 minutos
- 💻 **Sin GPU (CPU):** 38-64 minutos

> **Conclusión:** Si no tienes GPU o no sabes si la tienes, usa `WHISPER_MODEL=small` en el `.env`. Tardará 20-30 minutos por hora de audio, que sigue siendo muy rápido y confiable.

### 🖥️ Comparación de Modelos Whisper

| Modelo | RAM Necesaria | GPU Detectada | Sin GPU (CPU) | Precisión | Recomendado para |
|--------|---------------|---------------|---------------|-----------|------------------|
| tiny | ~1GB | Muy rápido | Rápido | Básica | Pruebas |
| base | ~1GB | Muy rápido | Rápido | Buena | Audio claro |
| **small** | **~2GB** | **Rápido** | **Aceptable** | **Muy buena** | **PCs sin GPU** ✅ |
| **medium** | **~5GB** | **Medio** | **Lento** | **Excelente** | **PCs con GPU** ✅ |
| large | ~10GB | Lento | Muy lento | Máxima | GPUs potentes |

> **¿Cómo saber cuál usar?**
> - No sabes si tienes GPU → Usa `small` (seguro y rápido)
> - Tienes GPU NVIDIA (RTX, GTX) → Usa `medium` (mejor calidad)
> - PC antiguo o básico → Usa `tiny` o `base` (más rápido)
> 
> El sistema detecta automáticamente tu hardware y se adapta.

## Modos de Operación

El sistema tiene 3 modos configurables en `.env`:

```env
MODE=full              # Transcribe + formatea (por defecto)
MODE=transcribe-only   # Solo transcribe
MODE=format-only       # Solo formatea archivos existentes
```

## Comandos Docker

```powershell
# Ver logs en tiempo real
docker-compose logs -f

# Detener servicios
docker-compose down

# Reconstruir desde cero
docker-compose build --no-cache

# Limpiar todo y empezar de nuevo
.\clean.ps1
```

## Arquitectura

```
┌─────────────────────────────────────┐
│  Docker Compose                     │
│  ┌───────────────────────────────┐  │
│  │  Servicio: Ollama             │  │
│  │  - LLM local (llama3.2:3b)    │  │
│  │  - Puerto: 11434              │  │
│  │  - Formateo de texto          │  │
│  └───────────────────────────────┘  │
│              ↓                      │
│  ┌───────────────────────────────┐  │
│  │  Servicio: Audio Transcriber  │  │
│  │  - Whisper (transcripción)    │  │
│  │  - FFmpeg (audio processing)  │  │
│  │  - Python 3.10                │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
         ↓              ↓
    input/         output/
```

## Documentación Adicional

- **[QUICKSTART.md](QUICKSTART.md)** - Guía de inicio rápido
- **[PROYECTO.md](PROYECTO.md)** - Arquitectura detallada
- **[WORKFLOW.md](WORKFLOW.md)** - Flujo de trabajo interno
- **[DISTRIBUCION.md](DISTRIBUCION.md)** - Cómo compartir el sistema

## Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `run.ps1` | **Ejecuta el sistema** (menú interactivo) |
| `verify.ps1` | Verifica que Docker esté correctamente instalado |
| `clean.ps1` | Limpia contenedores, imágenes y volúmenes |
| `build-package.ps1` | Empaqueta el sistema para distribución |
| `volume-manager.ps1` | Exporta/importa modelos descargados |

## Formateo Local vs API

### Ollama (Local - Recomendado)

- 100% gratuito
- Privado (datos no salen de tu computador)
- Sin límites de uso
- Requiere ~4GB RAM adicional

### Gemini (API)

- Requiere cuenta de Google y API key
- Tiene costos según uso
- Resultados de mayor calidad
- No requiere recursos locales

Para usar Gemini, cambia en `.env`:
```env
FORMATTER=gemini
GOOGLE_API_KEY=tu_clave_aqui
```

## Solución de Problemas

### "Docker no encontrado"

```powershell
# Instalar Docker Desktop desde:
# https://www.docker.com/products/docker-desktop
```

### "Out of memory"

```powershell
# Cambiar a modelo más ligero en .env
WHISPER_MODEL=small
OLLAMA_MODEL=llama3.2:1b
```

### "Puerto 11434 en uso"

```powershell
# Detener otros servicios Ollama
docker-compose down
docker ps -a | grep ollama
```

### Transcripción de mala calidad

```powershell
# Usar modelo más grande en .env
WHISPER_MODEL=large
```

## Contribuir

¡Contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-caracteristica`
3. Commit cambios: `git commit -m 'Agregar nueva característica'`
4. Push: `git push origin feature/nueva-caracteristica`
5. Abre un Pull Request

## Licencia

Este proyecto está bajo licencia MIT. Ver archivo `LICENSE` para más detalles.

## Créditos

- [OpenAI Whisper](https://github.com/openai/whisper) - Motor de transcripción
- [Ollama](https://ollama.ai/) - LLM local para formateo
- [FFmpeg](https://ffmpeg.org/) - Procesamiento de audio

## Soporte

¿Problemas o preguntas? Abre un [issue en GitHub](https://github.com/TU_USUARIO/NOMBRE_REPO/issues).

---

**Hecho con ❤️ para facilitar la transcripción de audio de larga duración**
