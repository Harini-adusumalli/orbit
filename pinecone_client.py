# pinecone_client.py
from pinecone import Pinecone
from config import PINECONE_API_KEY, INDEX_NAME
from model import get_embedding

# Initialize Pinecone
pc = Pinecone(api_key=PINECONE_API_KEY)
index = pc.Index(INDEX_NAME)

def query_alumni(query: str, top_k: int = 5):
    """Search Pinecone index for alumni."""
    vector = get_embedding(query)
    response = index.query(
        vector=vector,
        top_k=top_k,
        include_metadata=True
    )

    results = []
    for match in response["matches"]:
        results.append({
            "score": match["score"],
            "metadata": match["metadata"]
        })
    return results
