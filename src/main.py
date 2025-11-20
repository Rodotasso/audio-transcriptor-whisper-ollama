"""
Script principal que ejecuta tanto la transcripción como el formateo.
"""
import sys
import os
from pathlib import Path
import logging

# Importar los módulos de transcripción y formateo
from transcribe import AudioTranscriber
from format import TranscriptionFormatter

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/main.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


def main():
    """Función principal que coordina transcripción y formateo."""
    # Leer configuración
    mode = os.environ.get('MODE', 'full')  # full, transcribe-only, format-only
    model_name = os.environ.get('WHISPER_MODEL', 'medium')
    language = os.environ.get('AUDIO_LANGUAGE', 'es')
    input_dir = Path(os.environ.get('INPUT_DIR', '/app/input'))
    output_dir = Path(os.environ.get('OUTPUT_DIR', '/app/output'))
    
    logger.info("="*80)
    logger.info("SISTEMA DE TRANSCRIPCIÓN Y FORMATEO DE AUDIO")
    logger.info("="*80)
    logger.info(f"Modo: {mode}")
    logger.info(f"Directorio de entrada: {input_dir}")
    logger.info(f"Directorio de salida: {output_dir}")
    logger.info("="*80 + "\n")
    
    # PASO 1: Transcripción
    if mode in ['full', 'transcribe-only']:
        logger.info("\n" + "="*80)
        logger.info("PASO 1: TRANSCRIPCIÓN DE AUDIO")
        logger.info("="*80 + "\n")
        
        transcriber = AudioTranscriber(model_name=model_name, language=language)
        
        if not transcriber.load_model():
            logger.error("No se pudo cargar el modelo de Whisper. Terminando.")
            sys.exit(1)
        
        if input_dir.exists():
            transcriber.process_directory(input_dir, output_dir)
        else:
            logger.error(f"El directorio de entrada no existe: {input_dir}")
            sys.exit(1)
        
        logger.info("\nTranscripción completada.\n")
    
    # PASO 2: Formateo
    if mode in ['full', 'format-only']:
        logger.info("\n" + "="*80)
        logger.info("PASO 2: FORMATEO DE TRANSCRIPCIONES")
        logger.info("="*80 + "\n")
        
        # Determinar qué formateador usar
        formatter_type = os.environ.get('FORMATTER', 'ollama').lower()
        
        if formatter_type == 'ollama':
            # Usar Ollama (100% local, sin API key)
            logger.info("Usando formateador OLLAMA (local)")
            try:
                from format_ollama import OllamaFormatter
                
                ollama_model = os.environ.get('OLLAMA_MODEL', 'llama3.2:3b')
                ollama_host = os.environ.get('OLLAMA_HOST', 'http://ollama:11434')
                
                formatter = OllamaFormatter(model_name=ollama_model, ollama_host=ollama_host)
                
                if not formatter.check_ollama_available():
                    logger.error("Ollama no está disponible. Saltando formateo.")
                    logger.info("Asegúrate de que el contenedor de Ollama esté corriendo.")
                elif not formatter.ensure_model_available():
                    logger.error("No se pudo preparar el modelo de Ollama. Saltando formateo.")
                else:
                    formatter.process_directory(output_dir, output_dir)
                    logger.info("\nFormateo completado con Ollama.\n")
            except Exception as e:
                logger.error(f"Error al usar Ollama: {e}")
                logger.warning("Saltando formateo.")
        
        elif formatter_type == 'gemini':
            # Usar Gemini (requiere API key)
            logger.info("Usando formateador GEMINI (requiere API key)")
            api_key = os.environ.get('GOOGLE_API_KEY')
            
            if not api_key:
                logger.warning("No se proporcionó GOOGLE_API_KEY. Saltando el formateo.")
                logger.warning("Si deseas formatear con Gemini, configura GOOGLE_API_KEY en .env")
                logger.info("O cambia FORMATTER=ollama para usar formateo local.")
            else:
                model_name = os.environ.get('GEMINI_MODEL', 'gemini-1.5-pro-latest')
                formatter = TranscriptionFormatter(api_key=api_key, model_name=model_name)
                
                if not formatter.configure_api():
                    logger.error("No se pudo configurar la API de Gemini. Saltando formateo.")
                else:
                    formatter.process_directory(output_dir, output_dir)
                    logger.info("\nFormateo completado con Gemini.\n")
        else:
            logger.warning(f"Formateador desconocido: {formatter_type}")
            logger.warning("Usa FORMATTER=ollama o FORMATTER=gemini")
            logger.warning("Saltando formateo.")
    
    logger.info("\n" + "="*80)
    logger.info("PROCESAMIENTO COMPLETADO")
    logger.info("="*80)
    logger.info(f"Revisa los archivos de salida en: {output_dir}")
    logger.info(f"Revisa los logs en: /app/logs")
    logger.info("="*80 + "\n")


if __name__ == "__main__":
    main()
