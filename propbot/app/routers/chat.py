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
