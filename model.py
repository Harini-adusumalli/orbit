from sentence_transformers import SentenceTransformer
from config import MODEL_NAME

# Don't load the model immediately
model = None


def get_model():
    global model

    if model is None:
        print("Loading embedding model...")
        model = SentenceTransformer(MODEL_NAME)
        print("Embedding model loaded!")

    return model


def get_embedding(text: str):
    query_text = f"query: {text.strip()}"

    embedding_model = get_model()

    return embedding_model.encode(query_text).tolist()