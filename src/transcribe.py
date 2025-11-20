"""
Script principal para transcribir archivos de audio usando Whisper.
Adaptado para trabajar localmente con Docker.
"""
import whisper
import torch
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
        logging.FileHandler('/app/logs/transcription.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class AudioTranscriber:
    def __init__(self, model_name="medium", language="es"):
        """
        Inicializa el transcriptor de audio.
        
        Args:
            model_name: Modelo de Whisper a usar (tiny, base, small, medium, large)
            language: Idioma del audio (código ISO, ej: 'es' para español)
        """
        self.model_name = model_name
        self.language = language
        self.model = None
        self.device = self._setup_device()
        
        logger.info(f"Dispositivo seleccionado: {self.device}")
    
    def _setup_device(self):
        """
        Detecta y configura el dispositivo (GPU/CPU) con límite de VRAM.
        
        Returns:
            str: 'cuda' o 'cpu'
        """
        use_gpu = os.environ.get('USE_GPU', 'auto').lower()
        gpu_memory_limit = int(os.environ.get('GPU_MEMORY_LIMIT', '2048'))  # MB
        
        # Verificar disponibilidad de CUDA
        if not torch.cuda.is_available():
            logger.info("🖥️  GPU NVIDIA no detectada. Usando CPU.")
            return "cpu"
        
        # Si el usuario deshabilitó GPU
        if use_gpu in ['false', 'no', 'cpu']:
            logger.info(f"🖥️  GPU deshabilitada por configuración (USE_GPU={use_gpu}). Usando CPU.")
            return "cpu"
        
        # Obtener información de GPU
        try:
            gpu_name = torch.cuda.get_device_name(0)
            total_memory = torch.cuda.get_device_properties(0).total_memory / (1024**3)  # GB
            logger.info(f"🎮 GPU detectada: {gpu_name}")
            logger.info(f"📊 VRAM total disponible: {total_memory:.2f} GB")
            logger.info(f"⚙️  Límite configurado: {gpu_memory_limit} MB ({gpu_memory_limit/1024:.2f} GB)")
            
            # Configurar límite de memoria
            if gpu_memory_limit > 0:
                # PyTorch memory fraction
                fraction = (gpu_memory_limit / 1024) / total_memory
                if fraction > 0.95:
                    fraction = 0.95  # No usar más del 95% por seguridad
                    logger.warning(f"⚠️  Límite muy alto, ajustado a {fraction*100:.1f}%")
                
                torch.cuda.set_per_process_memory_fraction(fraction, device=0)
                logger.info(f"✅ Límite de VRAM aplicado: {gpu_memory_limit}MB = {fraction*100:.1f}% de GPU")
            
            return "cuda"
        except Exception as e:
            logger.warning(f"⚠️  Error configurando GPU: {e}. Usando CPU.")
            return "cpu"
        
    def load_model(self):
        """Carga el modelo de Whisper en memoria."""
        logger.info(f"Cargando modelo Whisper ({self.model_name})...")
        try:
            # Cargar modelo en el dispositivo configurado
            self.model = whisper.load_model(self.model_name, device=self.device)
            
            if self.device == "cuda":
                # Mostrar memoria GPU utilizada
                memory_allocated = torch.cuda.memory_allocated(0) / (1024**3)
                memory_reserved = torch.cuda.memory_reserved(0) / (1024**3)
                logger.info(f"✅ Modelo cargado en GPU")
                logger.info(f"📊 VRAM utilizada: {memory_allocated:.2f} GB (reservada: {memory_reserved:.2f} GB)")
            else:
                logger.info(f"✅ Modelo cargado en CPU")
            
            return True
        except Exception as e:
            logger.error(f"Error al cargar el modelo: {e}")
            if "out of memory" in str(e).lower():
                logger.error("⚠️  GPU sin memoria suficiente. Intenta:")
                logger.error("   1. Aumentar GPU_MEMORY_LIMIT en .env")
                logger.error("   2. Usar un modelo más pequeño (tiny, base, small)")
                logger.error("   3. Deshabilitar GPU con USE_GPU=false")
            return False
    
    def transcribe_file(self, audio_path, output_path=None):
        """
        Transcribe un archivo de audio.
        
        Args:
            audio_path: Ruta al archivo de audio
            output_path: Ruta donde guardar la transcripción (opcional)
        
        Returns:
            dict: Resultado de la transcripción con 'text', 'segments', etc.
        """
        if not self.model:
            logger.error("Modelo no cargado. Llama a load_model() primero.")
            return None
            
        audio_path = Path(audio_path)
        
        # Verificar que el archivo existe
        if not audio_path.exists():
            logger.error(f"El archivo no existe: {audio_path}")
            return None
        
        logger.info(f"Transcribiendo archivo: {audio_path.name}")
        logger.info(f"Tamaño del archivo: {audio_path.stat().st_size / (1024*1024):.2f} MB")
        
        try:
            # Transcribir el archivo
            # fp16=False para compatibilidad con CPUs
            result = self.model.transcribe(
                str(audio_path),
                language=self.language,
                fp16=False,
                verbose=True
            )
            
            transcription_text = result["text"]
            logger.info(f"Transcripción completada. Longitud: {len(transcription_text)} caracteres")
            
            # Guardar la transcripción
            if output_path:
                output_path = Path(output_path)
            else:
                # Crear nombre de archivo de salida basado en el de entrada
                output_path = Path("/app/output") / f"{audio_path.stem}_transcripcion.txt"
            
            # Asegurar que el directorio de salida existe
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Guardar el archivo
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(transcription_text)
            
            logger.info(f"Transcripción guardada en: {output_path}")
            
            # Guardar también la versión detallada con timestamps (opcional)
            detailed_path = output_path.parent / f"{audio_path.stem}_transcripcion_detallada.txt"
            with open(detailed_path, 'w', encoding='utf-8') as f:
                f.write(f"Transcripción de: {audio_path.name}\n")
                f.write(f"Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"Modelo: {self.model_name}\n")
                f.write(f"Idioma: {self.language}\n")
                f.write("="*80 + "\n\n")
                f.write("TRANSCRIPCIÓN COMPLETA:\n\n")
                f.write(transcription_text)
                f.write("\n\n" + "="*80 + "\n\n")
                f.write("SEGMENTOS CON TIMESTAMPS:\n\n")
                for segment in result.get("segments", []):
                    start = segment.get("start", 0)
                    end = segment.get("end", 0)
                    text = segment.get("text", "").strip()
                    f.write(f"[{start:.2f}s -> {end:.2f}s] {text}\n")
            
            logger.info(f"Versión detallada guardada en: {detailed_path}")
            
            return result
            
        except Exception as e:
            logger.error(f"Error durante la transcripción: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return None
    
    def process_directory(self, input_dir, output_dir=None):
        """
        Procesa todos los archivos de audio en un directorio.
        
        Args:
            input_dir: Directorio con archivos de audio
            output_dir: Directorio donde guardar las transcripciones
        """
        input_dir = Path(input_dir)
        output_dir = Path(output_dir) if output_dir else Path("/app/output")
        
        # Extensiones de audio soportadas por FFmpeg
        audio_extensions = {'.mp3', '.wav', '.m4a', '.flac', '.aac', '.ogg', '.wma', '.opus'}
        
        audio_files = [f for f in input_dir.iterdir() 
                      if f.is_file() and f.suffix.lower() in audio_extensions]
        
        if not audio_files:
            logger.warning(f"No se encontraron archivos de audio en: {input_dir}")
            return
        
        logger.info(f"Encontrados {len(audio_files)} archivo(s) de audio para procesar")
        
        processed = 0
        skipped = 0
        
        for idx, audio_file in enumerate(audio_files, 1):
            output_path = output_dir / f"{audio_file.stem}_transcripcion.txt"
            
            # Saltar si ya existe la transcripción
            if output_path.exists():
                logger.info(f"⏭️  Saltando {audio_file.name} (ya transcrito)")
                skipped += 1
                continue
            
            logger.info(f"\n{'='*80}")
            logger.info(f"Procesando archivo {idx}/{len(audio_files)}: {audio_file.name}")
            logger.info(f"{'='*80}\n")
            
            self.transcribe_file(audio_file, output_path)
            processed += 1
        
        logger.info(f"\n{'='*80}")
        logger.info(f"Resumen: {processed} procesados, {skipped} saltados")
        logger.info(f"{'='*80}\n")


def main():
    """Función principal."""
    # Configuración desde variables de entorno
    model_name = os.environ.get('WHISPER_MODEL', 'medium')
    language = os.environ.get('AUDIO_LANGUAGE', 'es')
    input_dir = Path(os.environ.get('INPUT_DIR', '/app/input'))
    output_dir = Path(os.environ.get('OUTPUT_DIR', '/app/output'))
    
    logger.info("="*80)
    logger.info("SERVICIO DE TRANSCRIPCIÓN DE AUDIO CON WHISPER")
    logger.info("="*80)
    logger.info(f"Modelo: {model_name}")
    logger.info(f"Idioma: {language}")
    logger.info(f"Directorio de entrada: {input_dir}")
    logger.info(f"Directorio de salida: {output_dir}")
    logger.info("="*80 + "\n")
    
    # Crear transcriptor
    transcriber = AudioTranscriber(model_name=model_name, language=language)
    
    # Cargar modelo
    if not transcriber.load_model():
        logger.error("No se pudo cargar el modelo. Terminando.")
        sys.exit(1)
    
    # Procesar archivos
    if input_dir.exists():
        transcriber.process_directory(input_dir, output_dir)
    else:
        logger.error(f"El directorio de entrada no existe: {input_dir}")
        sys.exit(1)
    
    logger.info("\n" + "="*80)
    logger.info("PROCESAMIENTO COMPLETADO")
    logger.info("="*80)


if __name__ == "__main__":
    main()
