"""
Script para formatear transcripciones usando Google Gemini API.
Toma transcripciones crudas y las formatea para mejorar legibilidad.
"""
import google.generativeai as genai
import os
import sys
from pathlib import Path
import logging
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


class TranscriptionFormatter:
    def __init__(self, api_key, model_name='gemini-1.5-pro-latest'):
        """
        Inicializa el formateador de transcripciones.
        
        Args:
            api_key: Clave API de Google Gemini
            model_name: Nombre del modelo de Gemini a usar
        """
        self.api_key = api_key
        self.model_name = model_name
        self.model = None
        
    def configure_api(self):
        """Configura la API de Google Gemini."""
        try:
            if not self.api_key:
                raise ValueError("API key de Google Gemini no proporcionada")
            
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel(self.model_name)
            logger.info(f"API de Google Gemini configurada con modelo: {self.model_name}")
            return True
        except Exception as e:
            logger.error(f"Error al configurar la API: {e}")
            return False
    
    def format_text(self, raw_text, custom_prompt=None):
        """
        Formatea un texto crudo usando Gemini.
        
        Args:
            raw_text: Texto crudo a formatear
            custom_prompt: Prompt personalizado (opcional)
        
        Returns:
            str: Texto formateado
        """
        if not self.model:
            logger.error("Modelo no configurado. Llama a configure_api() primero.")
            return None
        
        # Prompt por defecto
        if not custom_prompt:
            custom_prompt = """Por favor, toma la siguiente transcripción de audio y formatéala para mejorar significativamente su legibilidad. Realiza las siguientes acciones:
1. Divide el texto en párrafos coherentes donde haya cambios de tema, de hablante (si es discernible) o pausas largas implícitas. Usa doble salto de línea entre párrafos.
2. Corrige y añade la puntuación necesaria (comas, puntos, mayúsculas iniciales, signos de interrogación/exclamación donde corresponda).
3. Asegúrate de que las frases estén bien estructuradas gramaticalmente.
4. No añadas contenido, información o resúmenes que no estén en el texto original. Solo formatea el texto existente.
5. Mantén el idioma original de la transcripción.

Aquí está la transcripción cruda:

{texto_crudo}"""
        
        # Preparar el prompt
        prompt = custom_prompt.format(texto_crudo=raw_text)
        
        logger.info(f"Enviando texto a Gemini para formateo ({len(raw_text)} caracteres)...")
        
        try:
            response = self.model.generate_content(prompt)
            formatted_text = response.text
            logger.info(f"Texto formateado recibido ({len(formatted_text)} caracteres)")
            return formatted_text
        except Exception as e:
            logger.error(f"Error al formatear el texto: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return None
    
    def format_file(self, input_path, output_path=None):
        """
        Formatea un archivo de transcripción.
        
        Args:
            input_path: Ruta al archivo de transcripción cruda
            output_path: Ruta donde guardar el texto formateado (opcional)
        
        Returns:
            bool: True si se formateó exitosamente
        """
        input_path = Path(input_path)
        
        # Verificar que el archivo existe
        if not input_path.exists():
            logger.error(f"El archivo no existe: {input_path}")
            return False
        
        logger.info(f"Leyendo archivo: {input_path.name}")
        
        try:
            # Leer el contenido del archivo
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
                # Crear nombre de archivo de salida basado en el de entrada
                output_path = Path("/app/output") / f"{input_path.stem}_formateado.txt"
            
            # Asegurar que el directorio de salida existe
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Guardar el archivo formateado
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(f"Transcripción formateada de: {input_path.name}\n")
                f.write(f"Fecha de formateo: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"Modelo usado: {self.model_name}\n")
                f.write("="*80 + "\n\n")
                f.write(formatted_text)
            
            logger.info(f"Texto formateado guardado en: {output_path}")
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
        
        # Buscar archivos de texto que parezcan transcripciones (sin "_formateado")
        text_files = [f for f in input_dir.iterdir() 
                     if f.is_file() and f.suffix == '.txt' and '_formateado' not in f.name]
        
        if not text_files:
            logger.warning(f"No se encontraron archivos de texto para formatear en: {input_dir}")
            return
        
        logger.info(f"Encontrados {len(text_files)} archivo(s) de texto para formatear")
        
        success_count = 0
        for idx, text_file in enumerate(text_files, 1):
            logger.info(f"\n{'='*80}")
            logger.info(f"Procesando archivo {idx}/{len(text_files)}: {text_file.name}")
            logger.info(f"{'='*80}\n")
            
            output_path = output_dir / f"{text_file.stem}_formateado.txt"
            if self.format_file(text_file, output_path):
                success_count += 1
        
        logger.info(f"\nArchivos formateados exitosamente: {success_count}/{len(text_files)}")


def main():
    """Función principal."""
    # Configuración desde variables de entorno
    api_key = os.environ.get('GOOGLE_API_KEY')
    model_name = os.environ.get('GEMINI_MODEL', 'gemini-1.5-pro-latest')
    input_dir = Path(os.environ.get('INPUT_DIR', '/app/output'))  # Por defecto busca en output
    output_dir = Path(os.environ.get('OUTPUT_DIR', '/app/output'))
    
    logger.info("="*80)
    logger.info("SERVICIO DE FORMATEO DE TRANSCRIPCIONES CON GEMINI")
    logger.info("="*80)
    logger.info(f"Modelo: {model_name}")
    logger.info(f"Directorio de entrada: {input_dir}")
    logger.info(f"Directorio de salida: {output_dir}")
    logger.info("="*80 + "\n")
    
    if not api_key:
        logger.error("No se proporcionó GOOGLE_API_KEY. Configúrala en el archivo .env")
        logger.error("Puedes obtener una clave API en: https://makersuite.google.com/app/apikey")
        sys.exit(1)
    
    # Crear formateador
    formatter = TranscriptionFormatter(api_key=api_key, model_name=model_name)
    
    # Configurar API
    if not formatter.configure_api():
        logger.error("No se pudo configurar la API de Gemini. Terminando.")
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
