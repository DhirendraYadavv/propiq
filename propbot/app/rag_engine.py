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
