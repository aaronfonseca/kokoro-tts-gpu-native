from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from kokoro import KPipeline
import soundfile as sf
import os
import numpy as np
from uuid import uuid4
from pydub import AudioSegment
import io

# Initialize FastAPI app
app = FastAPI()

# Directory to save audio files
OUTPUT_DIR = "output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Serve the output directory statically
app.mount("/output", StaticFiles(directory=OUTPUT_DIR), name="output")

# Define request model
class SpeechRequest(BaseModel):
    text: str
    voice: str = "af_nicole"
    speed: float = 1.0
    lang_code: str = "a"

# POST endpoint to generate speech
@app.post("/generate-speech")
async def generate_speech(request: SpeechRequest):
    try:
        # Initialize Kokoro pipeline
        pipeline = KPipeline(lang_code=request.lang_code)
        
        # Generate audio
        generator = pipeline(
            request.text,
            voice=request.voice,
            speed=request.speed,
        )
        
        # Collect all audio segments
        all_audio = []
        for i, (gs, ps, audio) in enumerate(generator):
            all_audio.append(audio)
        
        # Concatenate audio segments
        if all_audio:
            concatenated_audio = np.concatenate(all_audio)
            
            # Generate unique filename
            filename = f"audio_{uuid4()}.mp3"
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            # Convert numpy array to bytes buffer
            buffer = io.BytesIO()
            sf.write(buffer, concatenated_audio, 24000, format='WAV')
            buffer.seek(0)
            
            # Convert to MP3 using pydub
            audio = AudioSegment.from_wav(buffer)
            audio.export(filepath, format="mp3")
            
            # Create URL
            url = f"http://localhost:8000/output/{filename}"
            return {"urls": [url]}
        else:
            raise HTTPException(status_code=500, detail="No audio generated")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating speech: {str(e)}")

# Optional: Root endpoint for testing
@app.get("/")
async def root():
    return {"message": "Kokoro TTS Server is running"}
