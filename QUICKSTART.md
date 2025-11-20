# Guía de Inicio Rápido - Para Principiantes

**Tiempo estimado:** 15-30 minutos (incluyendo instalación de Docker)

> **NOTA:** Este sistema NO funciona en móviles (Android/iOS). Requiere Docker Desktop que solo está disponible para Windows, Mac y Linux.

> **¿Necesito una GPU o tarjeta gráfica especial?**
> 
> **NO.** El sistema funciona en cualquier PC moderna:
> - ✅ Si tienes GPU NVIDIA: se usará automáticamente (más rápido)
> - ✅ Si NO tienes GPU: usará tu procesador normal (un poco más lento)
> - ✅ Si no sabes qué tienes: no importa, funcionará igual
> 
> El sistema detecta tu hardware automáticamente y se adapta.

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

## Paso 2: Abrir PowerShell en la carpeta del proyecto

1. **Abrir PowerShell:**
   - Abre la carpeta del proyecto
   - Mantén `Shift` y haz clic derecho en espacio vacío
   - Selecciona "Abrir ventana de PowerShell aquí"

**¡Listo!** No necesitas configurar nada manualmente. El menú interactivo se encargará de todo.

> **Nota:** El archivo `.env` se creará automáticamente la primera vez que ejecutes `.\run.ps1`

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

## Paso 4: Ejecutar el Menú Interactivo

En PowerShell (en la carpeta del proyecto), escribe:

```powershell
.\run.ps1
```

**Verás el menú interactivo:**

```
========================================
  🎙️  TRANSCRIPTOR DE AUDIO
  Whisper + Ollama (100% Local)
========================================

MENÚ PRINCIPAL

1. 🚀 Transcribir y Formatear (Proceso Completo)
2. 🎤 Solo Transcribir (Whisper)
3. ✨ Solo Formatear (Ollama)
4. 🔧 Configuración y Mantenimiento
5. 📊 Ver Estado del Sistema
6. 🗑️  Limpiar Archivos de Salida
7. ❌ Salir
```

**Primera vez: Selecciona opción 4 → opción 1 (Primera Instalación)**
- Construirá la imagen Docker (~10-15 min)
- Descargará modelos de Whisper (~3-5 GB)
- Descargará modelo Ollama (~2GB)
- **Total: ~5-7 GB | 15-30 minutos**

**Usos posteriores: Selecciona opción 1 (Proceso Completo)**
- Transcribe tus archivos automáticamente
- Formatea el texto con LLM
- Genera análisis completo
- Verás el progreso en pantalla

> **Importante:** La primera ejecución es lenta porque descarga modelos. Las siguientes serán rápidas.
> 
> **Todo es automático:** El menú te guiará paso a paso. No necesitas comandos manuales.

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

## Modelos Recomendados Según Tu PC

| Situación | Modelo | RAM | Con GPU | Sin GPU (CPU) |
|-----------|--------|-----|---------|---------------|
| PC antigua/básica | `tiny` | 1GB | 3 min | 6 min |
| **No sé si tengo GPU** | **`small`** | **2GB** | **8 min** | **20 min** ✅ |
| PC moderna con GPU | `medium` | 5GB | 15 min | 40 min |
| Máxima calidad | `large` | 10GB | 30 min | 90 min |

> **Recomendación:** Si no sabes si tienes GPU o qué modelo usar, deja la configuración por defecto (`small`). Funciona en todos los PCs y da excelentes resultados.

## Cambiar Configuración

**Opción 1: Desde el menú** (Recomendado)
- Ejecuta `.\run.ps1`
- Selecciona opción **4** (Configuración)
- Selecciona opción **3** (Editar archivo .env)

**Opción 2: Manual**

Edita `.env` con Bloc de notas:

```env
# Cambiar modelo de Whisper
WHISPER_MODEL=small  # tiny, base, small, medium, large

# Cambiar idioma
AUDIO_LANGUAGE=es  # es, en, fr, pt, etc.

# Español chileno optimizado (detecta modismos)
AUDIO_DIALECT=cl  # cl, mx, ar, es

# Desactivar análisis avanzado (más rápido)
ENABLE_SUMMARY=false
ENABLE_KEY_POINTS=false
ENABLE_TOPICS=false
```

## Limpiar Archivos de Salida

**Opción 1: Desde el menú** (Recomendado)
- Ejecuta `.\run.ps1`
- Selecciona opción **6** (Limpiar Archivos de Salida)

**Opción 2: Manual**

```powershell
Remove-Item .\output\* -Force
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
