"""
Formateador de transcripciones usando Ollama (modelo local).
Alternativa 100% local y gratuita a Gemini.
"""
import os
import sys
from pathlib import Path
import logging
import subprocess
import json
import requests
from datetime import datetime

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/formatting.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class OllamaFormatter:
    """Formateador usando Ollama con modelos locales."""
    
    def __init__(self, model_name='llama3.2:3b', ollama_host='http://ollama:11434'):
        """
        Inicializa el formateador con Ollama.
        
        Args:
            model_name: Modelo de Ollama a usar (llama3.2:3b es ligero y eficiente)
            ollama_host: URL del servidor Ollama
        """
        self.model_name = model_name
        self.ollama_host = ollama_host
        self.api_url = f"{ollama_host}/api/generate"
        
    def check_ollama_available(self):
        """Verifica si Ollama está disponible y corriendo."""
        try:
            response = requests.get(f"{self.ollama_host}/api/tags", timeout=5)
            if response.status_code == 200:
                logger.info("✓ Ollama está disponible")
                return True
        except Exception as e:
            logger.warning(f"Ollama no está disponible: {e}")
        return False
    
    def ensure_model_available(self):
        """Asegura que el modelo esté descargado."""
        try:
            logger.info(f"Verificando modelo {self.model_name}...")
            
            # Verificar si el modelo ya está descargado
            response = requests.get(f"{self.ollama_host}/api/tags")
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [m.get('name', '') for m in models]
                
                if self.model_name in model_names:
                    logger.info(f"✓ Modelo {self.model_name} ya está disponible")
                    return True
            
            # Si no está, intentar descargarlo
            logger.info(f"Descargando modelo {self.model_name}... (esto puede tardar)")
            pull_data = {"name": self.model_name}
            response = requests.post(
                f"{self.ollama_host}/api/pull",
                json=pull_data,
                stream=True,
                timeout=600
            )
            
            for line in response.iter_lines():
                if line:
                    try:
                        status = json.loads(line)
                        if 'status' in status:
                            logger.info(f"  {status['status']}")
                    except:
                        pass
            
            logger.info(f"✓ Modelo {self.model_name} descargado")
            return True
            
        except Exception as e:
            logger.error(f"Error al preparar el modelo: {e}")
            return False
    
    def format_text(self, raw_text, max_tokens=2000):
        """
        Formatea un texto usando Ollama.
        
        Args:
            raw_text: Texto crudo a formatear
            max_tokens: Número máximo de tokens a generar
        
        Returns:
            str: Texto formateado
        """
        if not raw_text.strip():
            logger.warning("Texto vacío, saltando formateo")
            return raw_text
        
        # Limitar el texto si es muy largo
        if len(raw_text) > 15000:
            logger.warning(f"Texto muy largo ({len(raw_text)} chars), procesando primeros 15000 caracteres")
            raw_text = raw_text[:15000] + "..."
        
        prompt = f"""Por favor, formatea la siguiente transcripción de audio para mejorar su legibilidad:

REGLAS:
1. Divide el texto en párrafos coherentes
2. Añade puntuación correcta (puntos, comas, mayúsculas)
3. Corrige errores gramaticales obvios
4. NO resumas, mantén todo el contenido
5. NO añadas información nueva
6. Usa doble salto de línea entre párrafos

TRANSCRIPCIÓN:
{raw_text}

TEXTO FORMATEADO:"""

        try:
            logger.info(f"Enviando texto a Ollama ({len(raw_text)} caracteres)...")
            
            payload = {
                "model": self.model_name,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.1,
                    "num_predict": max_tokens
                }
            }
            
            response = requests.post(
                self.api_url,
                json=payload,
                timeout=300  # 5 minutos timeout
            )
            
            if response.status_code == 200:
                result = response.json()
                formatted_text = result.get('response', '').strip()
                logger.info(f"✓ Texto formateado ({len(formatted_text)} caracteres)")
                return formatted_text
            else:
                logger.error(f"Error de Ollama: {response.status_code}")
                return raw_text
                
        except Exception as e:
            logger.error(f"Error al formatear: {e}")
            return raw_text
    
    def format_file(self, input_path, output_path=None):
        """
        Formatea un archivo de transcripción.
        
        Args:
            input_path: Ruta al archivo de transcripción cruda
            output_path: Ruta donde guardar el texto formateado
        
        Returns:
            bool: True si se formateó exitosamente
        """
        input_path = Path(input_path)
        
        if not input_path.exists():
            logger.error(f"El archivo no existe: {input_path}")
            return False
        
        logger.info(f"Procesando archivo: {input_path.name}")
        
        try:
            # Leer el contenido
            with open(input_path, 'r', encoding='utf-8') as f:
                raw_text = f.read()
            
            if not raw_text.strip():
                logger.warning(f"El archivo está vacío: {input_path}")
                return False
            
            logger.info(f"Texto leído ({len(raw_text)} caracteres)")
            
            # Formatear el texto
            formatted_text = self.format_text(raw_text)
            
            if not formatted_text:
                logger.error("No se pudo formatear el texto")
                return False
            
            # Determinar ruta de salida
            if output_path:
                output_path = Path(output_path)
            else:
                output_path = Path("/app/output") / f"{input_path.stem}_formateado.txt"
            
            # Guardar el archivo formateado
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(f"Transcripción formateada de: {input_path.name}\n")
                f.write(f"Fecha de formateo: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"Modelo usado: Ollama - {self.model_name}\n")
                f.write("="*80 + "\n\n")
                f.write(formatted_text)
            
            logger.info(f"✓ Texto formateado guardado en: {output_path}")
            return True
            
        except Exception as e:
            logger.error(f"Error al procesar el archivo: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return False
    
    def process_directory(self, input_dir, output_dir=None):
        """
        Procesa todos los archivos de texto en un directorio.
        
        Args:
            input_dir: Directorio con archivos de transcripción
            output_dir: Directorio donde guardar los textos formateados
        """
        input_dir = Path(input_dir)
        output_dir = Path(output_dir) if output_dir else Path("/app/output")
        
        # Buscar archivos de transcripción (sin "_formateado")
        text_files = [f for f in input_dir.iterdir() 
                     if f.is_file() and f.suffix == '.txt' 
                     and '_formateado' not in f.name
                     and '_detallada' not in f.name]
        
        if not text_files:
            logger.warning(f"No se encontraron archivos para formatear en: {input_dir}")
            return
        
        logger.info(f"Encontrados {len(text_files)} archivo(s) para formatear")
        
        success_count = 0
        for idx, text_file in enumerate(text_files, 1):
            logger.info(f"\n{'='*80}")
            logger.info(f"Procesando archivo {idx}/{len(text_files)}: {text_file.name}")
            logger.info(f"{'='*80}\n")
            
            output_path = output_dir / f"{text_file.stem}_formateado.txt"
            if self.format_file(text_file, output_path):
                success_count += 1
        
        logger.info(f"\n✓ Archivos formateados exitosamente: {success_count}/{len(text_files)}")


def main():
    """Función principal."""
    # Configuración desde variables de entorno
    model_name = os.environ.get('OLLAMA_MODEL', 'llama3.2:3b')
    ollama_host = os.environ.get('OLLAMA_HOST', 'http://ollama:11434')
    input_dir = Path(os.environ.get('INPUT_DIR', '/app/output'))
    output_dir = Path(os.environ.get('OUTPUT_DIR', '/app/output'))
    
    logger.info("="*80)
    logger.info("SERVICIO DE FORMATEO CON OLLAMA (100% LOCAL)")
    logger.info("="*80)
    logger.info(f"Modelo: {model_name}")
    logger.info(f"Ollama: {ollama_host}")
    logger.info(f"Directorio de entrada: {input_dir}")
    logger.info(f"Directorio de salida: {output_dir}")
    logger.info("="*80 + "\n")
    
    # Crear formateador
    formatter = OllamaFormatter(model_name=model_name, ollama_host=ollama_host)
    
    # Verificar Ollama
    if not formatter.check_ollama_available():
        logger.error("Ollama no está disponible. Asegúrate de que el contenedor esté corriendo.")
        logger.info("Para usar Ollama, ejecuta: docker-compose up -d ollama")
        sys.exit(1)
    
    # Asegurar que el modelo esté disponible
    if not formatter.ensure_model_available():
        logger.error("No se pudo preparar el modelo de Ollama.")
        sys.exit(1)
    
    # Procesar archivos
    if input_dir.exists():
        formatter.process_directory(input_dir, output_dir)
    else:
        logger.error(f"El directorio de entrada no existe: {input_dir}")
        sys.exit(1)
    
    logger.info("\n" + "="*80)
    logger.info("FORMATEO COMPLETADO")
    logger.info("="*80)


if __name__ == "__main__":
    main()
