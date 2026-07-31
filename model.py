# model.py
from sentence_transformers import SentenceTransformer
from config import MODEL_NAME

# Load embedding model once when the application starts
model = SentenceTransformer(MODEL_NAME)

def get_embedding(text: str):
    """Encode text into a vector embedding."""
    # The 'query: ' prefix is a specific instruction for the e5-large-v2 model
    # to format text for similarity search queries.
    query_text = f"query: {text.strip()}"
    return model.encode(query_text).tolist()