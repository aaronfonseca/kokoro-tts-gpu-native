# Kokoro tts gpu native

A Text-to-Speech (TTS) server built with FastAPI that generates audio files from text input using the `kokoro` library. The server accepts POST requests with text, voice, speed, and language parameters, returning a URL to the generated audio file.

## Why This Repository Exists

This repository was created to address a specific challenge when working with GPU-accelerated TTS in Docker environments:

While there is an official Docker image available for the Kokoro TTS system with GPU support (`ghcr.io/remsky/kokoro-fastapi-gpu:latest`), there's a known compatibility issue between Docker Desktop and NVIDIA CUDA drivers. When attempting to run NVIDIA/CUDA images on systems with Docker Desktop installed, you may encounter this error:

```
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
```

This is a persistent issue where Docker Desktop cannot properly recognize or utilize GPU drivers, while Docker Engine (on Linux) can. For developers working on applications that require local GPU acceleration but are using Docker Desktop, this presents a significant obstacle.

This repository provides a **native installation alternative** that bypasses Docker completely, allowing direct access to your system's GPU resources for TTS processing without the compatibility issues introduced by Docker Desktop.

## Prerequisites

- Python 3.8+
- `git` for cloning the repository
- `curl` or any HTTP client for testing (optional)

## Setup

1. **Clone the Repository**

   ```bash
   git clone git@github.com:aaronfonseca/kokoro-tts-gpu-native.git
   cd kokoro-tts-gpu-native
   ```

2. **Set Up Environment and Dependencies**

   ### Unix/Linux/macOS:
   Run the setup script to create a virtual environment, install dependencies, and start the server:

   ```bash
   chmod +x setup.sh  # Make the script executable (first time only)
   ./setup.sh
   ```

   ### Windows:
   Run the setup batch file to create a virtual environment, install dependencies, and start the server:

   ```
   setup.bat
   ```

   The server will be available at `http://localhost:8000`.

## Starting the Server (After Initial Setup)

After the initial setup, you can start the server using the activation scripts:

### Unix/Linux/macOS:
```bash
./activate_env.sh
```

### Windows:
```
activate_env.bat
```

These scripts will activate the virtual environment with the correct PATH settings and start the FastAPI server.

## Usage

Send a POST request to the `/generate-speech` endpoint with a JSON payload containing:

- `text`: The text to convert to speech.
- `voice`: The voice identifier (e.g., `am_adam`).
- `speed`: The speech speed (e.g., `1.1` for slightly faster than normal).
- `lang_code`: The language code (e.g., `a`).

### Example Request

```bash
curl --location 'http://localhost:8000/generate-speech' \
--header 'Content-Type: application/json' \
--data '{
    "text": "Scene #1\nThe tavern was alive with the raucous symphony of clinking mugs, boisterous laughter, and the occasional crash of a chair tipping over. The air was thick with the scent of roasted meats and the sharp tang of spilled ale, mingling with the earthy aroma of the wooden beams that framed the tavern. The flickering light from the hearth cast dancing shadows across the room, adding a sense of warmth and camaraderie to the bustling establishment.\n\nRemy and Jackal sat at a sturdy oak table near the center of the room, their presence commanding attention despite the lively crowd.",
    "voice": "am_adam",
    "speed": 1.1,
    "lang_code": "a"
}'
```

### Response

The server responds with a JSON object containing URL(s) to the generated audio file(s):

```json
{
  "urls": ["http://localhost:8000/output/audio_123abc.mp3"]
}
```

### Comparison with Docker Approach

If you don't have GPU requirements or are using Docker Engine on Linux, you can alternatively use the original Docker image with:

```bash
# Only works with Docker Engine (Linux), not with Docker Desktop
docker run --gpus all -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-gpu:latest
```

### Repository Structure
The repository includes:
```
kokoro-tts-gpu-native/
├── server.py          # FastAPI server code
├── requirements.txt   # Dependencies
├── setup.sh           # Setup script for Unix/Linux/macOS
├── setup.bat          # Setup script for Windows
├── activate_env.sh    # Activation script for Unix/Linux/macOS (Created by setup.sh)
├── activate_env.bat   # Activation script for Windows (Created by setup.bat)
└── README.md
```

## License

This project is licensed under the MIT License.