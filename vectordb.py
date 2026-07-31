from logging import config

from pinecone import Pinecone
from config import PINECONE_API_KEY, INDEX_NAME
# Initialize a Pinecone client with your API key
pc = Pinecone(api_key=PINECONE_API_KEY)

# Create a dense index with integrated embedding
index_name = INDEX_NAME
if not pc.has_index(index_name):
    pc.create_index_for_model(
        name=index_name,
        cloud="aws",
        region="us-east-1",
        embed={
            "model":"llama-text-embed-v2",
            "field_map":{"text": "chunk_text"}
        }
    )