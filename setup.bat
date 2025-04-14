@echo off
echo Starting setup for TTS server...

:: Create and activate virtual environment
if not exist "env1" (
    echo Creating virtual environment...
    python -m venv env1
) else (
    echo Virtual environment already exists.
)

:: Activate virtual environment
call env1\Scripts\activate.bat

:: Install dependencies
echo Installing dependencies from requirements.txt...
pip install --upgrade pip
pip install -r requirements.txt

:: Create local bin directory within the project
set LOCAL_BIN=%CD%\local\bin
if not exist "%LOCAL_BIN%" mkdir "%LOCAL_BIN%"

:: Add the local bin to PATH for this script
set PATH=%LOCAL_BIN%;%PATH%

:: Install ffmpeg locally if not already installed in our local path
where ffmpeg >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Installing ffmpeg locally...
    
    :: Create temporary directory for downloads
    set TMP_DIR=%CD%\tmp_ffmpeg
    if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
    cd "%TMP_DIR%"
    
    :: Download FFmpeg for Windows
    echo Downloading FFmpeg for Windows...
    curl -L -o ffmpeg.zip https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
    
    :: Extract the zip file
    echo Extracting FFmpeg...
    powershell -command "Expand-Archive -Path ffmpeg.zip -DestinationPath ."
    
    :: Copy ffmpeg and ffprobe to our local bin
    for /d %%i in (ffmpeg-*) do (
        copy "%%i\bin\ffmpeg.exe" "%LOCAL_BIN%\"
        copy "%%i\bin\ffprobe.exe" "%LOCAL_BIN%\"
    )
    
    :: Clean up
    cd ..
    rmdir /s /q "%TMP_DIR%"
    
    echo FFmpeg installed locally.
) else (
    echo FFmpeg already available in PATH.
)

:: Create a script to help activate the environment with the correct PATH
echo @echo off > activate_env.bat
echo call "%CD%\env1\Scripts\activate.bat" >> activate_env.bat
echo set PATH=%CD%\local\bin;%%PATH%% >> activate_env.bat
echo echo Environment activated with local FFmpeg. >> activate_env.bat
echo uvicorn server:app --host 0.0.0.0 --port 8000 >> activate_env.bat

:: Verify ffmpeg for pydub
echo Verifying ffmpeg installation...
ffmpeg -version

:: Start the server
echo Starting FastAPI server...
uvicorn server:app --host 0.0.0.0 --port 8000

echo For future use, activate the environment with: activate_env.bat
