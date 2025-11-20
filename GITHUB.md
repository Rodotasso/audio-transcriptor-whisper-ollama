# 📤 GUÍA DE PUBLICACIÓN EN GITHUB

## 🎯 Objetivo

Hacer que el proyecto sea **cloneable y reproducible** desde GitHub sin incluir archivos grandes.

---

## ✅ Preparación del Repositorio

### 1. Verificar qué se subirá

```powershell
# Ver archivos que Git rastreará
git status
git ls-files

# Verificar que .gitignore funciona
git check-ignore input/ output/ *.tar
```

### 2. Renombrar README

```powershell
# Reemplazar README actual con la versión de GitHub
Move-Item README.md README-LOCAL.md -Force
Move-Item README-GITHUB.md README.md
```

### 3. Estructura Final para GitHub

```
📁 Repositorio (todo se clona automáticamente)
├── .gitignore              ✅ Excluye archivos grandes
├── .env.example            ✅ Plantilla de configuración
├── docker-compose.yml      ✅ Orquestación
├── Dockerfile              ✅ Imagen base con Whisper
├── requirements.txt        ✅ Dependencias Python
├── README.md               ✅ Documentación principal
├── QUICKSTART.md           ✅ Guía rápida
├── PROYECTO.md             ✅ Arquitectura
├── WORKFLOW.md             ✅ Flujo interno
├── DISTRIBUCION.md         ✅ Cómo compartir
├── run.ps1                 ✅ Script principal
├── verify.ps1              ✅ Verificador
├── clean.ps1               ✅ Limpieza
├── build-package.ps1       ✅ Empaquetador
├── volume-manager.ps1      ✅ Gestor de volúmenes
└── src/                    ✅ Código Python
    ├── main.py
    ├── transcribe.py
    ├── format.py
    └── format_ollama.py

❌ NO se suben (en .gitignore):
├── input/                  # Archivos del usuario
├── output/                 # Resultados
├── logs/                   # Logs
├── .env                    # Configuración personal
├── *.tar                   # Imágenes Docker
├── package/                # Paquetes generados
└── volume-backup/          # Backups de modelos
```

---

## 🚀 Publicar en GitHub

### Opción A: Nuevo Repositorio desde Cero

```powershell
# 1. Inicializar Git (si no existe)
git init

# 2. Agregar archivos
git add .

# 3. Verificar qué se agregó (NO debe aparecer .env, *.tar, input/, etc.)
git status

# 4. Primer commit
git commit -m "Initial commit: Sistema de transcripción con Whisper y Ollama"

# 5. Crear repo en GitHub (hacer manualmente en github.com)
# Nombre sugerido: audio-transcriptor-whisper-ollama

# 6. Conectar con GitHub
git remote add origin https://github.com/Rodotasso/audio-transcriptor-whisper-ollama.git

# 7. Subir
git branch -M main
git push -u origin main
```

### Opción B: Repositorio Existente

```powershell
# 1. Agregar cambios
git add .

# 2. Commit
git commit -m "feat: Sistema completo de transcripción con Ollama local"

# 3. Push
git push
```

---

## 🎯 Flujo de Reproducción (Usuario Final)

Cuando alguien clone tu repositorio:

```powershell
# 1. Clonar (descarga ~5MB de código)
git clone https://github.com/TU_USUARIO/audio-transcriptor-whisper-ollama.git
cd audio-transcriptor-whisper-ollama

# 2. Configurar
Copy-Item .env.example .env
# Opcional: editar .env con sus preferencias

# 3. Ejecutar (descarga modelos automáticamente ~5GB)
.\run.ps1
```

**Proceso automático:**
1. Docker Compose construye imagen con Whisper (~4GB)
2. Primera ejecución descarga modelo Ollama (~2GB)
3. Modelos quedan en volúmenes Docker (persistentes)
4. Siguientes ejecuciones son instantáneas

---

## 📋 Checklist Pre-Publicación

Antes de hacer `git push`, verificar:

### Archivos Esenciales
- [ ] `.gitignore` actualizado (excluye *.tar, .env, input/, output/)
- [ ] `README.md` completo con instrucciones de clonado
- [ ] `.env.example` con valores por defecto seguros
- [ ] Todos los scripts `.ps1` tienen comentarios claros
- [ ] `Dockerfile` pre-descarga modelos Whisper

### Configuración
- [ ] `.env` NO está en el repositorio (verificar con `git status`)
- [ ] No hay claves API en el código
- [ ] Rutas son relativas (no absolutas de tu PC)

### Documentación
- [ ] README explica cómo clonar y ejecutar
- [ ] QUICKSTART tiene ejemplo de 3 pasos
- [ ] DISTRIBUCION explica las 3 opciones
- [ ] Cada script tiene descripción clara

### Testing
- [ ] Probado en directorio limpio: `git clone` → `run.ps1` funciona
- [ ] Verificado que no hay dependencias externas raras
- [ ] Scripts funcionan en PowerShell por defecto

---

## 🎨 Mejoras Opcionales para GitHub

### 1. Agregar LICENSE

```powershell
# Crear archivo LICENSE con MIT License
@"
MIT License

Copyright (c) 2025 TU_NOMBRE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ | Out-File LICENSE -Encoding utf8
```

### 2. Agregar Badges al README

```markdown
# 🎤 Sistema de Transcripción y Formateo de Audio

[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.10-green.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Whisper](https://img.shields.io/badge/Whisper-OpenAI-orange.svg)](https://github.com/openai/whisper)
[![Ollama](https://img.shields.io/badge/Ollama-Local%20LLM-purple.svg)](https://ollama.ai/)
```

### 3. Agregar Capturas de Pantalla

Crea carpeta `docs/` con screenshots:
```powershell
New-Item -ItemType Directory docs
# Agregar capturas de run.ps1, output, etc.
```

### 4. GitHub Actions (CI/CD) - Opcional

Crear `.github/workflows/docker-build.yml`:
```yaml
name: Docker Build Test
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker Image
        run: docker-compose build
```

---

## 📊 Comparación: GitHub vs Paquete Manual

| Aspecto | GitHub Clone | Paquete .zip Manual |
|---------|--------------|---------------------|
| **Tamaño descarga inicial** | ~5 MB | 8-12 GB |
| **Requiere internet** | ✅ Sí (primera vez) | ❌ No |
| **Actualizaciones** | `git pull` | Re-descargar todo |
| **Setup tiempo** | 20-30 min | 2-5 min |
| **Mejor para** | Desarrollo, colaboración | Distribución offline |

---

## 🔄 Workflow Completo

```powershell
# === DESARROLLO LOCAL ===
# Trabajas normalmente
.\run.ps1

# === PUBLICAR EN GITHUB ===
# 1. Preparar
Move-Item README.md README-LOCAL.md -Force
Move-Item README-GITHUB.md README.md

# 2. Commit
git add .
git status  # Verificar que NO aparecen .env, *.tar, input/
git commit -m "Update: Mejoras en transcripción"
git push

# === USUARIO FINAL DESCARGA ===
# Otro usuario clona
git clone https://github.com/TU_USUARIO/tu-repo.git
cd tu-repo
Copy-Item .env.example .env
.\run.ps1  # Descarga modelos automáticamente
```

---

## ⚠️ Cosas que NUNCA Subir

```
❌ .env (contiene configuración personal)
❌ *.tar (imágenes Docker, demasiado grandes)
❌ input/ (archivos privados del usuario)
❌ output/ (resultados privados)
❌ logs/ (logs locales)
❌ package/ (paquetes generados)
❌ API keys o contraseñas
❌ Modelos pre-descargados (*.pt, ollama-data)
```

---

## ✅ Validación Final

Antes de publicar, prueba en un directorio limpio:

```powershell
# Simular clonado fresco
cd D:\TEMP
git clone tu_repo_url
cd tu_repo

# Verificar archivos
ls  # Debe verse limpio, sin .tar ni carpetas grandes

# Probar ejecución
Copy-Item .env.example .env
.\run.ps1  # Debe funcionar y descargar modelos
```

---

## 🎯 Resumen

**Para GitHub (Recomendado para desarrollo):**
- ✅ Solo código (~5MB)
- ✅ Fácil de mantener y actualizar
- ✅ Colaboración con otros
- ✅ Issues y Pull Requests
- ⚠️ Requiere internet en primera ejecución

**Para Paquete Manual (Ver DISTRIBUCION.md):**
- ✅ Todo incluido (8-12GB)
- ✅ 100% offline después de descarga
- ✅ Ideal para ambientes restringidos
- ⚠️ Difícil de actualizar

**Puedes hacer AMBOS:** Repositorio en GitHub + Releases con paquetes pre-construidos.

---

**Última actualización:** 19 de noviembre de 2025
