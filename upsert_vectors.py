import pandas as pd
import uuid
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer
from config import PINECONE_API_KEY, INDEX_NAME, CSV_PATH, CREATE_INDEX
RECREATE_INDEX = CREATE_INDEX         # Set to False if index already exists

# === INIT PINECONE ===
pc = Pinecone(api_key=PINECONE_API_KEY)

# === (OPTIONAL) DELETE & RECREATE INDEX ===
if RECREATE_INDEX:
    if INDEX_NAME in [i.name for i in pc.list_indexes()]:
        print(f"🗑️ Deleting existing index '{INDEX_NAME}'...")
        pc.delete_index(INDEX_NAME)

    print(f"🆕 Creating index '{INDEX_NAME}' with dimension=1024...")
    pc.create_index(
        name=INDEX_NAME,
        dimension=1024,
        metric="cosine",
        spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"
        )
    )

index = pc.Index(INDEX_NAME)

# === LOAD EMBEDDING MODEL ===
print("🔄 Loading embedding model...")
model = SentenceTransformer("intfloat/e5-large-v2")
print("✅ Model loaded.")

# === LOAD CSV DATA ===
df = pd.read_csv(CSV_PATH).astype(str)

# === HELPER: Convert important fields to string for embedding
def row_to_string(row):
    return f"""Industry: {row.get('Industry', '')}
Designation: {row.get('Designation', '')}
Technical_Skills: {row.get('Technical_Skills', '')}
Notable_Projects: {row.get('Notable_Projects', '')}
Mentorship_Area: {row.get('Mentorship_Area', '')}
Current_Company: {row.get('Current_Company', '')}
Interests: {row.get('Interests', '')}
Willing_to_Mentor: {row.get('Willing_to_Mentor', '')}
Years_of_Experience: {row.get('Years_of_Experience', '')}
"""

# === CREATE VECTORS ===
vectors = []

for _, row in df.iterrows():
    text = row_to_string(row)
    embedding = model.encode("passage: " + text).tolist()  # Proper format for E5 model

    vector = {
        "id": str(uuid.uuid4()),
        "values": embedding,
        "metadata": row.to_dict()  # Full row kept for rich metadata
    }
    vectors.append(vector)

# === UPSERT TO PINECONE ===
if vectors:
    print(f"⬆️  Upserting {len(vectors)} vectors to Pinecone...")
    index.upsert(vectors=vectors)
    print("✅ Upsert complete.")
else:
    print("⚠️ No vectors generated.")
