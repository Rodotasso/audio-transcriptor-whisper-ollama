# Guía de Inicio Rápido - Para Principiantes

**Tiempo estimado:** 15-30 minutos (incluyendo instalación de Docker)

> **NOTA:** Este sistema NO funciona en móviles (Android/iOS). Requiere Docker Desktop que solo está disponible para Windows, Mac y Linux.

---

## Paso 0: Instalar Docker Desktop (Solo Primera Vez)

### ¿Qué es Docker?
Docker es un programa que permite ejecutar aplicaciones en "contenedores" aislados. Es como una máquina virtual ligera.

### Instalación:

1. **Descargar Docker Desktop:**
   - Ve a: https://www.docker.com/products/docker-desktop
   - Haz clic en "Download for Windows"
   - Descarga el instalador (~500 MB)

2. **Instalar:**
   - Ejecuta el instalador descargado
   - Acepta los términos y condiciones
   - Deja las opciones por defecto
   - **Reinicia tu computador** cuando te lo pida

3. **Verificar instalación:**
   - Abre Docker Desktop desde el menú Inicio
   - Espera a que diga "Docker is running" (luz verde)
   - ¡Listo! Docker está funcionando

> **Nota:** Docker Desktop requiere Windows 10/11 Pro o usar WSL2 en Windows Home

---

## Paso 1: Descargar el Proyecto

### Opción A: Si tienes Git instalado

1. **Abrir PowerShell:**
   - Presiona `Windows + X`
   - Selecciona "Windows PowerShell" o "Terminal"

2. **Clonar repositorio:**
   ```powershell
   cd D:\
   git clone https://github.com/TU_USUARIO/NOMBRE_REPO.git
   cd NOMBRE_REPO
   ```

### Opción B: Si NO tienes Git (Más fácil)

1. **Descargar ZIP:**
   - Ve al repositorio en GitHub
   - Haz clic en el botón verde "Code"
   - Selecciona "Download ZIP"

2. **Extraer:**
   - Haz clic derecho en el archivo ZIP
   - Selecciona "Extraer todo..."
   - Elige una carpeta (ejemplo: `D:\transcriptor`)

3. **Abrir PowerShell en esa carpeta:**
   - Abre la carpeta extraída
   - Mantén `Shift` y haz clic derecho en espacio vacío
   - Selecciona "Abrir ventana de PowerShell aquí"

---

## Paso 2: Configurar (1 minuto)

En la ventana de PowerShell que abriste, ejecuta:

```powershell
Copy-Item .env.example .env
```

**Eso es todo.** El sistema ya está configurado con valores por defecto que funcionan.

> **Opcional:** Si quieres cambiar la configuración, edita el archivo `.env` con Bloc de notas

---

## Paso 3: Agregar tus archivos de audio
```powershell
# Navegar a la carpeta del proyecto (si no estás ahí)
cd D:\transcriptor  # Cambia por tu ruta

# Copiar archivos de audio
Copy-Item "D:\Mis Audios\entrevista.mp3" .\input\
```

**O simplemente:**
1. Abre la carpeta `input` del proyecto
2. Arrastra y suelta tus archivos `.mp3`, `.m4a`, `.wav`, etc.

---

## Paso 4: Ejecutar la Transcripción

En PowerShell (en la carpeta del proyecto), escribe:

```powershell
.\run.ps1
```

**¿Qué pasará?**
1. Se abrirá un menú interactivo
2. Selecciona la opción `2` (Ejecutar transcripción) o `1` (primera vez)
3. **Primera vez:** El script automáticamente:
   - Iniciará el servicio Ollama
   - Verificará si el modelo llama3.2:3b está descargado
   - Si NO está descargado, lo descargará automáticamente (~2GB, 5-10 min)
   - Descargará modelos de Whisper (~3-5 GB, 10-20 min)
   - **Total: ~5-7 GB | 15-30 minutos**
4. Transcribirá tus archivos automáticamente
5. Verás el progreso en pantalla

> **Importante:** La primera ejecución es lenta porque descarga modelos. Las siguientes serán rápidas.
> 
> **Modelo Ollama:** El script `run.ps1` se encarga de verificar y descargar automáticamente el modelo si no existe. No necesitas ejecutar ningún comando manual.

---

## Paso 5: Ver tus Transcripciones

1. Abre la carpeta `output` del proyecto
2. Encontrarás hasta 6 archivos por cada audio:
   - `nombre_transcripcion.txt` → **Texto limpio** (úsalo para leer)
   - `nombre_transcripcion_detallada.txt` → Con marcas de tiempo
   - `nombre_transcripcion_formateada.txt` → Formateado profesional
   - `nombre_resumen.txt` → Resumen ejecutivo
   - `nombre_puntos_clave.txt` → Puntos importantes
   - `nombre_temas.txt` → Temas principales

**¡Listo!** Ya puedes copiar el texto y usarlo donde necesites.

## Modelos Recomendados

| Situación | Modelo | RAM | Tiempo (1h audio) |
|-----------|--------|-----|-------------------|
| Prueba rápida | `tiny` | 1GB | ~5 min |
| Uso general | `small` | 2GB | ~10 min |
| **Recomendado** | `medium` | 5GB | ~20 min |
| Máxima calidad | `large` | 10GB | ~40 min |

## Cambiar Configuración

Edita `.env`:
```env
# Solo transcribir (sin formateo)
MODE=transcribe-only

# Cambiar modelo
WHISPER_MODEL=small

# Cambiar idioma
AUDIO_LANGUAGE=en

# Desactivar análisis avanzado
ENABLE_SUMMARY=false
ENABLE_KEY_POINTS=false
ENABLE_TOPICS=false
```

## Limpiar todo

```powershell
.\clean.ps1
```

## Problemas Comunes

**Error de memoria**: Usa un modelo más pequeño
```env
WHISPER_MODEL=small
```

**No formatea**: Verifica que `GOOGLE_API_KEY` esté configurada en `.env`

**Idioma incorrecto**: Cambia `AUDIO_LANGUAGE=es` al código correcto

---

Ver [README.md](README.md) para documentación completa.
