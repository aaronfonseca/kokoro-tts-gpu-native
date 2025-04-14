#!/bin/bash

# Exit on any error
set -e

echo "Starting setup for TTS server..."

# Check for Python3 and venv on Linux (Debian-based)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$OS" = "linux" ]; then
    if ! command -v python3 &> /dev/null || ! python3 -m venv --help &> /dev/null; then
        echo "Python3 or python3-venv not found. Installing..."
        sudo apt update
        sudo apt install -y python3 python3-venv
    else
        echo "Python3 and venv are already installed."
    fi
fi

# Create and activate virtual environment
if [ ! -d "env1" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "env1"
    if [ ! -f "env1/bin/activate" ]; then
        echo "Failed to create virtual environment. Check Python installation."
        exit 1
    fi
else
    echo "Virtual environment already exists."
fi

source env1/bin/activate

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r "requirements.txt"

# Create local bin directory within the project
LOCAL_BIN="$(pwd)/local/bin"
mkdir -p "$LOCAL_BIN"

# Add the local bin to PATH for this script
export PATH="$LOCAL_BIN:$PATH"

# Install ffmpeg locally if not already installed in our local path
if ! command -v ffmpeg &> /dev/null; then
    echo "Installing ffmpeg locally..."
    
    # Create temporary directory for downloads
    TMP_DIR="$(pwd)/tmp_ffmpeg"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
    
    # Detect architecture
    ARCH=$(uname -m)
    
    if [ "$OS" = "linux" ]; then
        if [ "$ARCH" = "x86_64" ]; then
            # For Linux x86_64
            echo "Downloading FFmpeg for Linux x86_64..."
            wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
            tar xf ffmpeg-release-amd64-static.tar.xz
            # Find the extracted directory - it includes the version number
            EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "ffmpeg-*" | head -n 1)
            cp "$EXTRACTED_DIR/ffmpeg" "$LOCAL_BIN/"
            cp "$EXTRACTED_DIR/ffprobe" "$LOCAL_BIN/"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            # For Linux ARM64
            echo "Downloading FFmpeg for Linux ARM64..."
            wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz
            tar xf ffmpeg-release-arm64-static.tar.xz
            EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "ffmpeg-*" | head -n 1)
            cp "$EXTRACTED_DIR/ffmpeg" "$LOCAL_BIN/"
            cp "$EXTRACTED_DIR/ffprobe" "$LOCAL_BIN/"
        else
            echo "Unsupported architecture: $ARCH. Please install FFmpeg manually."
            exit 1
        fi
    elif [ "$OS" = "darwin" ]; then
        # For macOS
        echo "Downloading FFmpeg for macOS..."
        # Using homebrew formula without installing it system-wide
        wget -q https://evermeet.cx/ffmpeg/getrelease/ffmpeg/7.0
        unzip getrelease.ffmpeg.7.0
        cp ./ffmpeg "$LOCAL_BIN/"
        
        wget -q https://evermeet.cx/ffmpeg/getrelease/ffprobe/7.0
        unzip getrelease.ffprobe.7.0
        cp ./ffprobe "$LOCAL_BIN/"
    else
        echo "Unsupported OS: $OS. Please install FFmpeg manually."
        exit 1
    fi
    
    # Make executables
    chmod +x "$LOCAL_BIN/ffmpeg"
    chmod +x "$LOCAL_BIN/ffprobe"
    
    # Clean up
    cd ..
    rm -rf "$TMP_DIR"
    
    echo "FFmpeg installed locally."
else
    echo "FFmpeg already available in PATH."
fi

# Create a script to help activate the environment with the correct PATH
cat > activate_env.sh << 'EOF'
#!/bin/bash
# Activate environment with the correct PATH
source "$(dirname "$0")/env1/bin/activate"
export PATH="$(dirname "$0")/local/bin:$PATH"
echo "Environment activated with local FFmpeg."
uvicorn server:app --host 0.0.0.0 --port 8000
EOF

chmod +x activate_env.sh

# Verify ffmpeg for pydub
echo "Verifying ffmpeg installation..."
ffmpeg -version

# Start the server
echo "Starting FastAPI server..."
uvicorn server:app --host 0.0.0.0 --port 8000

echo "For future use, activate the environment with: ./activate_env.sh"