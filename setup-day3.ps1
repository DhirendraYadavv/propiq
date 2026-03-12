# PropIQ Day 3 - FastAPI + PropBot RAG Setup
# Run from: C:\Users\User\propiq

Write-Host "Setting up Day 3 - FastAPI + PropBot..." -ForegroundColor Cyan

# Create propbot directory
$base = "C:\Users\User\propiq\propbot"
New-Item -ItemType Directory -Force -Path $base | Out-Null
New-Item -ItemType Directory -Force -Path "$base\app" | Out-Null
New-Item -ItemType Directory -Force -Path "$base\app\routers" | Out-Null
New-Item -ItemType Directory -Force -Path "$base\data" | Out-Null

Write-Host "Created directory structure" -ForegroundColor Green

# requirements.txt - compatible with Python 3.14
Set-Content -Path "$base\requirements.txt" -Encoding utf8 -Value @'
fastapi==0.115.6
uvicorn[standard]==0.32.1
httpx==0.28.1
pydantic==2.10.3
python-dotenv==1.0.1
openai==1.58.1
numpy==2.2.0
'@

Write-Host "Created requirements.txt" -ForegroundColor Green

# .env file
Set-Content -Path "$base\.env" -Encoding utf8 -Value @'
OPENAI_API_KEY=your-openai-api-key-here
SPRING_BACKEND_URL=http://localhost:8080
'@

Write-Host "Created .env" -ForegroundColor Green

# Indian tenancy law knowledge base
Set-Content -Path "$base\data\tenancy_laws.txt" -Encoding utf8 -Value @'
INDIAN RENTAL AND TENANCY LAW KNOWLEDGE BASE

=== MODEL TENANCY ACT 2021 ===
The Model Tenancy Act 2021 was introduced by the Indian government to regulate the rental housing market.
Key provisions:
- Security deposit capped at 2 months rent for residential and 6 months for commercial properties
- Landlord must provide rent receipt for all payments
- Written rent agreement mandatory for all tenancies
- Landlord cannot cut essential services like water and electricity
- 24 hours notice required before landlord entry except emergency
- Tenant must pay rent by 5th of each month unless agreed otherwise
- Sub-letting requires written permission from landlord

=== RENT INCREASE RULES ===
- Rent can only be increased as per terms in the agreement
- Minimum 3 months advance notice required for rent increase
- Annual rent increase cannot exceed 5-10% depending on state
- Rent increase during fixed term not allowed without consent
- Market rate revision allowed only after lease expiry

=== SECURITY DEPOSIT RULES ===
- Maximum security deposit: 2 months rent for residential properties
- Security deposit must be returned within 30 days of vacating
- Landlord can deduct for actual damages beyond normal wear and tear
- Interest on security deposit: some states require 4-6% per annum
- Receipt mandatory when collecting security deposit

=== EVICTION RULES ===
- Landlord cannot evict without proper notice period
- Notice period: minimum 1 month for monthly tenancy
- Notice period: minimum 3 months for annual tenancy
- Valid grounds for eviction: non-payment, subletting without permission, property damage
- Forceful eviction is illegal - must go through Rent Authority
- Tenant can challenge eviction notice within 30 days

=== TDS ON RENT - SECTION 194-IB ===
- TDS applicable when monthly rent exceeds Rs 50,000
- TDS rate: 2% on rent amount (reduced from 5% from Oct 2024)
- TDS to be deducted in last month of tenancy or March
- TAN not required for individual/HUF landlords
- Form 26QC to be filed within 30 days of TDS deduction
- Tenant must issue Form 16C to landlord within 15 days
- Non-deduction penalty: equal to TDS amount
- PAN of landlord mandatory for TDS compliance

=== LATE PAYMENT RULES ===
- Late fee chargeable after grace period (usually 5-10 days)
- Maximum late fee: 1-2% per month on outstanding amount
- Compound interest on late fees not allowed
- Late payment notice must be given in writing
- Consistent late payment (3+ months) is valid eviction ground

=== LEASE AGREEMENT ESSENTIALS ===
- Names and addresses of landlord and tenant
- Property description and address
- Monthly rent amount and due date
- Security deposit amount
- Lease start and end date
- Notice period for termination
- Maintenance responsibilities
- Pet and modification policies
- Registered lease mandatory for leases over 11 months
- Stamp duty applicable on lease registration

=== STATE-SPECIFIC RULES ===
Karnataka:
- Karnataka Rent Control Act applies to properties below Rs 3500/month rent
- Security deposit maximum: 10 months rent in some cases
- Rent increase: 5% per annum

Maharashtra:
- Maharashtra Rent Control Act 1999
- Security deposit: negotiable, typically 2-3 months
- Mumbai: high security deposits up to 12 months common but not legally required

Delhi:
- Delhi Rent Control Act 1958 (properties below Rs 3500/month)
- Rent increase: 10% every 3 years for controlled properties

Tamil Nadu:
- Tamil Nadu Regulation of Rights and Responsibilities of Landlords and Tenants Act 2017
- Security deposit: 5% of property value or negotiated amount

=== MAINTENANCE RESPONSIBILITIES ===
Landlord responsibilities:
- Structural repairs (walls, roof, foundation)
- Major plumbing and electrical work
- Pest control for major infestations
- Common area maintenance

Tenant responsibilities:
- Minor repairs under Rs 1000-5000 (as per agreement)
- Keeping property clean
- Minor plumbing like tap washers
- Garden maintenance if applicable
- Restoring property to original condition at end of lease

=== DISPUTE RESOLUTION ===
- Rent Authority: first point of contact for disputes
- Notice to Rent Authority must be filed within prescribed time
- Alternative: consumer forum for service-related issues
- Civil court for property damage claims above threshold
- Mediation encouraged before litigation
- Online dispute resolution available in some states
'@

Write-Host "Created tenancy laws knowledge base" -ForegroundColor Green

# Main FastAPI app
Set-Content -Path "$base\app\main.py" -Encoding utf8 -Value @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import chat, health
import uvicorn

app = FastAPI(
    title="PropBot AI",
    description="AI-powered property management assistant for Indian landlords",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(chat.router)

@app.get("/")
def root():
    return {"service": "PropBot AI", "status": "running", "version": "1.0.0"}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
'@

Write-Host "Created main.py" -ForegroundColor Green

# Health router
Set-Content -Path "$base\app\routers\health.py" -Encoding utf8 -Value @'
from fastapi import APIRouter
from datetime import datetime

router = APIRouter(prefix="/health", tags=["Health"])

@router.get("")
def health_check():
    return {
        "status": "healthy",
        "service": "PropBot AI",
        "timestamp": datetime.now().isoformat()
    }
'@

Write-Host "Created health router" -ForegroundColor Green

# RAG engine
Set-Content -Path "$base\app\rag_engine.py" -Encoding utf8 -Value @'
import os
import re
from pathlib import Path

# Simple in-memory RAG without vector DB - compatible with Python 3.14
class SimpleRAG:
    def __init__(self):
        self.chunks = []
        self._load_knowledge_base()

    def _load_knowledge_base(self):
        data_path = Path(__file__).parent.parent / "data" / "tenancy_laws.txt"
        if not data_path.exists():
            print(f"Warning: Knowledge base not found at {data_path}")
            return
        
        with open(data_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Split into chunks by section
        sections = content.split("\n===")
        for section in sections:
            section = section.strip()
            if len(section) > 100:
                # Further split long sections into paragraphs
                paragraphs = section.split("\n\n")
                for para in paragraphs:
                    para = para.strip()
                    if len(para) > 50:
                        self.chunks.append(para)
        
        print(f"Loaded {len(self.chunks)} knowledge chunks")

    def _simple_score(self, query: str, chunk: str) -> float:
        query_words = set(re.findall(r'\w+', query.lower()))
        chunk_words = set(re.findall(r'\w+', chunk.lower()))
        if not query_words:
            return 0.0
        overlap = query_words.intersection(chunk_words)
        return len(overlap) / len(query_words)

    def retrieve(self, query: str, top_k: int = 3) -> list[str]:
        if not self.chunks:
            return []
        scored = [(self._simple_score(query, chunk), chunk) for chunk in self.chunks]
        scored.sort(key=lambda x: x[0], reverse=True)
        return [chunk for score, chunk in scored[:top_k] if score > 0]

# Singleton instance
rag = SimpleRAG()
'@

Write-Host "Created RAG engine" -ForegroundColor Green

# Chat router
Set-Content -Path "$base\app\routers\chat.py" -Encoding utf8 -Value @'
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/chat", tags=["PropBot Chat"])

class ChatRequest(BaseModel):
    message: str
    context: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    sources_used: int
    mode: str

def get_fallback_reply(message: str, context_chunks: list) -> str:
    """Rule-based fallback when no OpenAI key is set"""
    msg = message.lower()
    context_text = " ".join(context_chunks)
    
    if any(word in msg for word in ["tds", "tax", "194-ib", "deduct"]):
        return (
            "TDS on rent is governed by Section 194-IB of Income Tax Act. "
            "TDS applies when monthly rent exceeds Rs 50,000. "
            "The rate is 2% (reduced from Oct 2024). "
            "File Form 26QC within 30 days and issue Form 16C to landlord within 15 days. "
            "TAN is not required for individual/HUF landlords."
        )
    elif any(word in msg for word in ["deposit", "security", "refund"]):
        return (
            "Under the Model Tenancy Act 2021, security deposit is capped at 2 months rent "
            "for residential properties and 6 months for commercial. "
            "The deposit must be returned within 30 days of vacating. "
            "Deductions allowed only for actual damages beyond normal wear and tear."
        )
    elif any(word in msg for word in ["evict", "eviction", "notice", "vacate"]):
        return (
            "Eviction requires proper notice: minimum 1 month for monthly tenancy, "
            "3 months for annual tenancy. Valid grounds include non-payment of rent, "
            "subletting without permission, or property damage. "
            "Forceful eviction is illegal - landlord must approach the Rent Authority."
        )
    elif any(word in msg for word in ["rent increase", "hike", "increase rent"]):
        return (
            "Rent can only be increased as per the terms in the agreement. "
            "Minimum 3 months advance notice is required. "
            "Annual increase typically cannot exceed 5-10% depending on state. "
            "Rent cannot be increased during a fixed-term lease without tenant consent."
        )
    elif any(word in msg for word in ["maintenance", "repair", "responsibility"]):
        return (
            "Landlord is responsible for structural repairs, major plumbing/electrical work, "
            "and pest control. Tenant is responsible for minor repairs, keeping the property "
            "clean, and restoring it to original condition at end of lease."
        )
    elif any(word in msg for word in ["late", "overdue", "penalty", "fine"]):
        return (
            "Late fees are chargeable after the grace period (usually 5-10 days). "
            "Maximum late fee is typically 1-2% per month on outstanding amount. "
            "Compound interest on late fees is not allowed. "
            "Consistent late payment for 3+ months is valid ground for eviction."
        )
    elif context_chunks:
        # Return most relevant chunk as answer
        return f"Based on Indian tenancy law: {context_chunks[0]}"
    else:
        return (
            "I can help you with Indian rental law questions including TDS on rent, "
            "security deposit rules, eviction procedures, lease agreements, and maintenance "
            "responsibilities. Please ask a specific question about your rental situation."
        )

@router.post("", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    
    # Import RAG
    from app.rag_engine import rag
    context_chunks = rag.retrieve(request.message, top_k=3)
    
    api_key = os.getenv("OPENAI_API_KEY", "")
    
    if api_key and api_key != "your-openai-api-key-here":
        # Use OpenAI if key is set
        try:
            from openai import OpenAI
            client = OpenAI(api_key=api_key)
            
            context_text = "\n\n".join(context_chunks) if context_chunks else "No specific context found."
            
            system_prompt = """You are PropBot, an AI assistant specialized in Indian rental and property law. 
You help Indian landlords and tenants understand their rights and obligations.
Answer questions based on the provided context from Indian tenancy laws.
Be concise, practical, and always mention relevant acts or sections when applicable.
If unsure, recommend consulting a legal professional."""

            user_prompt = f"""Context from Indian tenancy laws:
{context_text}

User question: {request.message}

Provide a helpful, accurate answer based on Indian rental law."""

            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                max_tokens=500,
                temperature=0.3
            )
            
            reply = response.choices[0].message.content
            return ChatResponse(reply=reply, sources_used=len(context_chunks), mode="openai-rag")
            
        except Exception as e:
            # Fall back to rule-based if OpenAI fails
            reply = get_fallback_reply(request.message, context_chunks)
            return ChatResponse(reply=reply, sources_used=len(context_chunks), mode="fallback")
    else:
        # Rule-based RAG (no API key needed)
        reply = get_fallback_reply(request.message, context_chunks)
        return ChatResponse(reply=reply, sources_used=len(context_chunks), mode="rule-based-rag")

@router.get("/test")
def test_chat():
    return {
        "message": "PropBot is ready",
        "sample_questions": [
            "What is the TDS rule for rent above 50000?",
            "How much security deposit can a landlord charge?",
            "What is the notice period for eviction?",
            "Can landlord increase rent during lease period?"
        ]
    }
'@

Write-Host "Created chat router" -ForegroundColor Green

# __init__ files
Set-Content -Path "$base\app\__init__.py" -Encoding utf8 -Value ""
Set-Content -Path "$base\app\routers\__init__.py" -Encoding utf8 -Value ""

# run.py
Set-Content -Path "$base\run.py" -Encoding utf8 -Value @'
import uvicorn

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
'@

Write-Host "Created run.py" -ForegroundColor Green

# start.ps1 - easy start script
Set-Content -Path "$base\start.ps1" -Encoding utf8 -Value @'
Write-Host "Installing dependencies..." -ForegroundColor Cyan
pip install -r requirements.txt

Write-Host "Starting PropBot on port 8000..." -ForegroundColor Green
python run.py
'@

Write-Host "Created start.ps1" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Day 3 Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files created in: C:\Users\User\propiq\propbot" -ForegroundColor White
Write-Host ""
Write-Host "Next step - run in a NEW PowerShell window:" -ForegroundColor Yellow
Write-Host "  cd C:\Users\User\propiq\propbot" -ForegroundColor White
Write-Host "  pip install -r requirements.txt" -ForegroundColor White
Write-Host "  python run.py" -ForegroundColor White
Write-Host ""
Write-Host "PropBot will start on http://localhost:8000" -ForegroundColor Green
Write-Host "Swagger docs at http://localhost:8000/docs" -ForegroundColor Green
