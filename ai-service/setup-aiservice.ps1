Write-Host "Creating PropIQ AI Service..." -ForegroundColor Cyan

$base = "C:\Users\User\propiq\ai-service"

# main.py
@'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import os

app = FastAPI(title="PropIQ AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "your-gemini-api-key-here")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

SYSTEM_PROMPT = """You are PropBot, an expert on Indian rental laws and property management.
You help landlords and tenants understand:
- TDS on rent (Section 194-IB): 10% TDS when monthly rent exceeds Rs 50,000
- Security deposits: typically 2-3 months rent, refundable
- Eviction rules: proper notice periods required (usually 15-30 days)
- Lease agreements: must be registered if over 11 months
- Rent control laws vary by state
- Police verification (Form C) mandatory for tenants
Keep answers concise, practical, and specific to Indian law."""

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    reply: str

@app.get("/health")
def health():
    return {"status": "ok", "service": "PropIQ AI"}

@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        prompt = f"{SYSTEM_PROMPT}\n\nUser: {req.message}\nPropBot:"
        response = model.generate_content(prompt)
        return ChatResponse(reply=response.text)
    except Exception as e:
        return ChatResponse(reply=f"Error: {str(e)}")
'@ | Set-Content -Path "$base\main.py" -Encoding UTF8

# requirements.txt
@'
fastapi==0.111.0
uvicorn==0.29.0
google-generativeai==0.5.4
pydantic==2.7.1
python-dotenv==1.0.1
'@ | Set-Content -Path "$base\requirements.txt" -Encoding UTF8

# .env
@'
GEMINI_API_KEY=your-gemini-api-key-here
'@ | Set-Content -Path "$base\.env" -Encoding UTF8

# start.bat
@'
@echo off
echo Starting PropIQ AI Service...
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
'@ | Set-Content -Path "$base\start.bat" -Encoding UTF8

Write-Host "  [OK] main.py" -ForegroundColor Green
Write-Host "  [OK] requirements.txt" -ForegroundColor Green
Write-Host "  [OK] .env" -ForegroundColor Green
Write-Host "  [OK] start.bat" -ForegroundColor Green
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " AI Service files created!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Add your Gemini API key to .env" -ForegroundColor Yellow
Write-Host "  2. cd C:\Users\User\propiq\ai-service" -ForegroundColor Yellow
Write-Host "  3. pip install -r requirements.txt" -ForegroundColor Yellow
Write-Host "  4. uvicorn main:app --port 8000 --reload" -ForegroundColor Yellow
