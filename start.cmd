@echo off
cd /d "%~dp0"
echo Serving Toyota Heritage PH at http://localhost:5173  (Ctrl+C to stop)
start "" "http://localhost:5173/"
python -m http.server 5173
