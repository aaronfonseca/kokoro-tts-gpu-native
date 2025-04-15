# Kokoro TTS GPU Native

A Text-to-Speech (TTS) server built with FastAPI that generates audio files from text input using the [Kokoro](https://github.com/remsky/kokoro) library. The server accepts POST requests with text, voice, speed, and language parameters, returning a URL to the generated audio file in MP3 format.

## Why This Repository Exists

This repository provides a **native installation alternative** for GPU-accelerated TTS, bypassing compatibility issues with Docker Desktop and NVIDIA CUDA drivers. When running NVIDIA/CUDA images on systems with Docker Desktop, you may encounter this error:

```
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
```

Docker Engine on Linux avoids this issue, but Docker Desktop does not reliably support GPU drivers. This project enables direct access to your system's GPU for TTS processing without Docker-related obstacles. Additionally, it uses `pydub` to generate compact MP3 audio files instead of the standard WAV files, reducing file size and improving compatibility for web applications.

## Prerequisites

- NVIDIA GPU with CUDA 11.x or higher and compatible drivers
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

   ```bash
   setup.bat
   ```

   After running the setup script, the server will be running at `http://localhost:8000`. You can verify this by visiting `http://localhost:8000/` or using the health-check curl command listed in the **Testing** section. If you encounter issues, ensure Python 3.8+ is installed and try running `pip install -r requirements.txt` manually after activating the virtual environment. For Japanese or Mandarin Chinese support, install the additional dependencies listed in the **Usage**.

## Starting the Server (After Initial Setup)

After the initial setup, use the activation scripts to start the server each time. These scripts activate the virtual environment and launch the FastAPI server at `http://localhost:8000`.

### Unix/Linux/macOS:
```bash
./activate_env.sh
```

### Windows:
```bash
activate_env.bat
```

## Usage

Send a POST request to the `/generate-speech` endpoint with a JSON payload containing:

- `text`: The text to convert to speech.
- `voice`: The voice identifier (e.g., `am_adam` for American English male). See [Kokoro documentation](https://github.com/remsky/kokoro) for available voices.
- `speed`: The speech speed (e.g., `1.0` for normal, `1.1` for slightly faster).
- `lang_code`: The language code (must match the `voice`):
  - `'a'`: 🇺🇸 American English
  - `'b'`: 🇬🇧 British English
  - `'j'`: 🇯🇵 Japanese (`pip install misaki[ja]`)
  - `'z'`: 🇨🇳 Mandarin Chinese (`pip install misaki[zh]`)

The server uses the `pydub` library to convert the Kokoro library's standard WAV output to MP3 format, resulting in smaller file sizes suitable for web and mobile applications.

### Example Request

```bash
curl --location 'http://localhost:8000/generate-speech' \
--header 'Content-Type: application/json' \
--data '{
    "text": "Scene #1\nThe tavern was alive with the raucous symphony of clinking mugs, boisterous laughter, and the occasional crash of a chair tipping over. The air was thick with the scent of roasted meats and the sharp tang of spilled ale, mingling with the earthy aroma of the wooden beams that framed the tavern.",
    "voice": "am_adam",
    "speed": 1.1,
    "lang_code": "a"
}'
```

### Response

The server responds with a JSON object containing the URL to the generated MP3 audio file:

```json
{
  "url": "http://localhost:8000/output/audio_1728934567.mp3"
}
```

### Error Handling

Invalid requests (e.g., unsupported voice, mismatched `lang_code` and `voice`, or missing dependencies) return an error response:

```json
{
  "error": "Invalid voice identifier or mismatched language code"
}
```

### Testing

After starting the server, you can verify it’s running with the health-check endpoint.
```bash
curl http://localhost:8000/
```

This returns a JSON response indicating the server’s status.
```json
{
  "message": "Kokoro TTS Server is running"
}
```

Alternatively, visit [http://localhost:8000/docs](http://localhost:8000/docs) to access the FastAPI Swagger UI for interactive testing, or use the example curl commands above.

## Comparison with Docker Approach

If you don't need a native installation or are using Docker Engine on Linux, you can use the official Docker image:

```bash
# Requires Docker Engine (Linux) and NVIDIA Container Toolkit
docker run --gpus all -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-gpu:latest
```

This runs the server at `http://localhost:8880`. 

Note that this approach is incompatible with Docker Desktop due to GPU driver issues.

## Repository Structure

```
kokoro-tts-gpu-native/
├── server.py           # FastAPI server implementation
├── requirements.txt    # Python dependencies
├── setup.sh            # Setup script for Unix/Linux/macOS
├── setup.bat           # Setup script for Windows
├── activate_env.sh     # Activation script for Unix/Linux/macOS
├── activate_env.bat    # Activation script for Windows
└── README.md           # Project documentation
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.