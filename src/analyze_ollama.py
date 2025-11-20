"""
Módulo para análisis avanzado de transcripciones usando Ollama.
Genera resúmenes, puntos clave y análisis de temas.
"""
import os
import requests
import logging

logger = logging.getLogger(__name__)

class TranscriptionAnalyzer:
    def __init__(self, ollama_url="http://ollama:11434", model="llama3.2:3b"):
        self.ollama_url = ollama_url
        self.model = model
        self.max_chunk_size = 15000
        
    def _call_ollama(self, prompt, context=""):
        """Llama a Ollama con un prompt específico."""
        full_prompt = f"{context}\n\n{prompt}" if context else prompt
        
        try:
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": self.model,
                    "prompt": full_prompt,
                    "stream": False
                },
                timeout=300
            )
            response.raise_for_status()
            return response.json()["response"]
        except Exception as e:
            logger.error(f"Error al llamar Ollama: {e}")
            return None
    
    def _chunk_text(self, text):
        """Divide el texto en chunks si es muy largo."""
        if len(text) <= self.max_chunk_size:
            return [text]
        
        chunks = []
        words = text.split()
        current_chunk = []
        current_length = 0
        
        for word in words:
            word_length = len(word) + 1
            if current_length + word_length > self.max_chunk_size:
                chunks.append(" ".join(current_chunk))
                current_chunk = [word]
                current_length = word_length
            else:
                current_chunk.append(word)
                current_length += word_length
        
        if current_chunk:
            chunks.append(" ".join(current_chunk))
        
        return chunks
    
    def generate_summary(self, transcription):
        """
        Genera un resumen ejecutivo de la transcripción.
        """
        logger.info("Generando resumen ejecutivo...")
        
        chunks = self._chunk_text(transcription)
        
        if len(chunks) == 1:
            prompt = f"""Genera un resumen ejecutivo de la siguiente transcripción. 
El resumen debe:
- Capturar las ideas principales
- Ser conciso pero completo (3-5 párrafos)
- Mantener la información más relevante
- Estar en español

Transcripción:
{transcription}

Resumen ejecutivo:"""
            
            return self._call_ollama(prompt)
        else:
            # Procesar chunks y luego resumir todo
            partial_summaries = []
            for i, chunk in enumerate(chunks):
                logger.info(f"Resumiendo chunk {i+1}/{len(chunks)}...")
                prompt = f"""Resume brevemente el siguiente fragmento de transcripción:

{chunk}

Resumen breve:"""
                partial = self._call_ollama(prompt)
                if partial:
                    partial_summaries.append(partial)
            
            # Resumen final de todos los resúmenes parciales
            combined = "\n\n".join(partial_summaries)
            final_prompt = f"""Genera un resumen ejecutivo cohesivo basado en estos resúmenes parciales:

{combined}

Resumen ejecutivo final (3-5 párrafos):"""
            
            return self._call_ollama(final_prompt)
    
    def generate_key_points(self, transcription):
        """
        Extrae los puntos clave más importantes de la transcripción.
        """
        logger.info("Extrayendo puntos clave...")
        
        chunks = self._chunk_text(transcription)
        all_points = []
        
        for i, chunk in enumerate(chunks):
            if len(chunks) > 1:
                logger.info(f"Extrayendo puntos del chunk {i+1}/{len(chunks)}...")
            
            prompt = f"""Extrae los puntos clave más importantes de la siguiente transcripción.

Instrucciones:
- Lista los puntos en formato bullet (•)
- Incluye solo información relevante y específica
- Máximo 10 puntos por transcripción
- Sé conciso pero claro
- En español

Transcripción:
{chunk}

Puntos clave:"""
            
            points = self._call_ollama(prompt)
            if points:
                all_points.append(points)
        
        if len(all_points) > 1:
            # Consolidar puntos de múltiples chunks
            combined_points = "\n\n".join(all_points)
            consolidate_prompt = f"""Consolida los siguientes puntos clave en una lista única sin duplicados:

{combined_points}

Lista consolidada de puntos clave (máximo 15 puntos):"""
            
            return self._call_ollama(consolidate_prompt)
        
        return all_points[0] if all_points else None
    
    def generate_topics(self, transcription):
        """
        Identifica los temas principales discutidos en la transcripción.
        """
        logger.info("Identificando temas principales...")
        
        # Para temas, usamos el inicio y final de la transcripción como muestra
        sample_size = self.max_chunk_size * 2
        if len(transcription) > sample_size:
            # Tomar inicio y final
            sample = transcription[:sample_size//2] + "\n...\n" + transcription[-sample_size//2:]
        else:
            sample = transcription
        
        prompt = f"""Analiza la siguiente transcripción e identifica los temas principales.

Instrucciones:
- Lista entre 3 y 8 temas principales
- Cada tema en formato: "Tema: breve descripción"
- Ordena por relevancia (más importante primero)
- Sé específico y claro
- En español

Transcripción:
{sample}

Temas principales:"""
        
        return self._call_ollama(prompt)
    
    def generate_complete_analysis(self, transcription):
        """
        Genera un análisis completo: resumen + puntos clave + temas.
        Retorna un diccionario con cada componente.
        """
        logger.info("Iniciando análisis completo de la transcripción...")
        
        analysis = {}
        
        # Resumen
        summary = self.generate_summary(transcription)
        if summary:
            analysis['summary'] = summary
            logger.info("✓ Resumen generado")
        
        # Puntos clave
        key_points = self.generate_key_points(transcription)
        if key_points:
            analysis['key_points'] = key_points
            logger.info("✓ Puntos clave extraídos")
        
        # Temas
        topics = self.generate_topics(transcription)
        if topics:
            analysis['topics'] = topics
            logger.info("✓ Temas identificados")
        
        return analysis
