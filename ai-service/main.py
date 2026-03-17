from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os, httpx
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

SYSTEM_PROMPT = """You are PropBot, an AI assistant for PropIQ.
You have access to the user's real property data shown below.
Use this data to answer specific questions about their properties, tenants, rent, and leases.
Also help with Indian rental law: TDS, security deposits, eviction rules.
Keep answers concise. Max 4 sentences."""

class ChatRequest(BaseModel):
    message: str
    token: str = ""

class ChatResponse(BaseModel):
    reply: str

def fetch_user_data(token: str) -> str:
    if not token:
        return ""
    try:
        headers = {"Authorization": f"Bearer {token}"}
        base = "http://localhost:8080"
        props = httpx.get(f"{base}/api/properties", headers=headers, timeout=5).json()
        tenants = httpx.get(f"{base}/api/tenants", headers=headers, timeout=5).json()
        leases = httpx.get(f"{base}/api/leases", headers=headers, timeout=5).json()
        summary = "USER PROPERTY DATA:\n"
        if props.get("data"):
            summary += f"Properties ({len(props['data'])} total):\n"
            for p in props["data"]:
                summary += f"  - {p.get('name','?')} at {p.get('address','?')}, rent: Rs {p.get('monthlyRent','?')}/month\n"
        if tenants.get("data"):
            summary += f"Tenants ({len(tenants['data'])} total):\n"
            for t in tenants["data"]:
                summary += f"  - {t.get('name','?')}\n"
        if leases.get("data"):
            summary += f"Leases ({len(leases['data'])} total):\n"
            for l in leases["data"]:
                summary += f"  - Rent: Rs {l.get('monthlyRent','?')}, status: {l.get('status','?')}, ends: {l.get('endDate','?')}\n"
        return summary
    except:
        return ""

@app.get("/health")
def health():
    return {"status": "ok", "service": "PropIQ AI"}

@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        user_data = fetch_user_data(req.token)
        system = SYSTEM_PROMPT
        if user_data:
            system += "\n\n" + user_data
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": req.message}
            ],
            max_tokens=400
        )
        return ChatResponse(reply=response.choices[0].message.content)
    except Exception as e:
        return ChatResponse(reply=f"Error: {str(e)}")