from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

app = FastAPI(title="PropIQ AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyCEETnfK9k0mCFpUdros3yBTlaqpIheDnY")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-2.0-flash")

SYSTEM_PROMPT = """You are PropBot, an expert on Indian rental laws and property management.
You help landlords and tenants understand:
- TDS on rent (Section 194-IB): 10% TDS when monthly rent exceeds Rs 50,000
- Security deposits: typically 2-3 months rent, refundable
- Eviction rules: proper notice periods required (usually 15-30 days)
- Lease agreements: must be registered if over 11 months
- Police verification (Form C) mandatory for tenants
Keep answers concise, practical, specific to Indian law. Max 3-4 sentences."""


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
