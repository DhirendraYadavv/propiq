from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from openai import OpenAI
from pathlib import Path

load_dotenv(dotenv_path=Path(__file__).parent / ".env")

app = FastAPI(title="PropIQ AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000", "http://15.207.159.218"],
    allow_methods=["*"],
    allow_headers=["*"],
)

client = OpenAI(
    api_key=os.getenv("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)

SYSTEM_PROMPT = """You are PropBot, an AI assistant for PropIQ - a property management app for Indian landlords.
Help with: TDS on rent, security deposits, eviction rules, lease agreements, police verification.
Keep answers concise, practical, India-specific. Max 3-4 sentences."""

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
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": req.message}
            ],
            max_tokens=300
        )
        return ChatResponse(reply=response.choices[0].message.content)
    except Exception as e:
        return ChatResponse(reply=f"Error: {str(e)}")
