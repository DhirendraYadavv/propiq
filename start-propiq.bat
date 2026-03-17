@echo off
echo Starting PropIQ...
echo.

echo [1/4] Starting Database...
docker start propiq-db

echo [2/4] Starting FastAPI AI Service...
start cmd /k "cd C:\Users\User\propiq\ai-service && python -m uvicorn main:app --port 8000"

echo [3/4] Starting React Frontend...
start cmd /k "cd C:\Users\User\propiq\frontend && npm run dev"

echo [4/4] Open IntelliJ and run BackendApplication.java manually
echo.
echo Done! Open http://localhost:5173 in browser
pause
