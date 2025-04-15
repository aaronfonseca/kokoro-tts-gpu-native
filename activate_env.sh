#!/bin/bash
# Activate environment with the correct PATH
source "$(dirname "$0")/env1/bin/activate"
export PATH="$(dirname "$0")/local/bin:$PATH"
uvicorn server:app --host 0.0.0.0 --port 8000
