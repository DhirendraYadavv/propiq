from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from openai import OpenAI

app = FastAPI(title="PropIQ AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000", "http://15.207.159.218"],
    allow_methods=["*"],
    allow_headers=["*"],
)

client = OpenAI(
    api_key="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",
    base_url="https://api.groq.com/openai/v1"
)

SYSTEM_PROMPT = """You are PropBot, an AI assistant built into PropIQ - a property management app for Indian landlords.
You help landlords and tenants understand:
- TDS on rent (Section 194-IB): 10% TDS when monthly rent exceeds Rs 50,000
- Security deposits: typically 2-3 months rent, refundable within 30 days of vacating
- Eviction rules: proper notice periods required (15-30 days depending on state)
- Lease agreements: must be registered if over 11 months, stamp duty applicable
- Police verification (Form C) mandatory for new tenants
- Maintenance responsibilities: structural repairs are landlord's duty
- Rent increase: typically capped at 10% per year, must be in lease agreement
Keep answers concise, practical, specific to Indian law. Max 3-4 sentences per answer."""

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    reply: str

@app.get("/health")
def health():
    return {"status": "ok", "service": "PropIQ AI", "model": "llama-3.3-70b"}

@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": req.message}
            ],
            max_tokens=300,
            temperature=0.7
        )
        return ChatResponse(reply=response.choices[0].message.content)
    except Exception as e:
        return ChatResponse(reply=f"Error: {str(e)}")
