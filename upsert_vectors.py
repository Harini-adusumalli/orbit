import pandas as pd
import uuid
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer
from config import PINECONE_API_KEY, INDEX_NAME, CSV_PATH

# ===========================================================
# Set True only when you want to recreate the Pinecone index
# ===========================================================
RECREATE_INDEX = False

# ===========================================================
# Initialize Pinecone
# ===========================================================
pc = Pinecone(api_key=PINECONE_API_KEY)

# ===========================================================
# Delete & Recreate Index
# ===========================================================
if RECREATE_INDEX:

    existing_indexes = [i.name for i in pc.list_indexes()]

    if INDEX_NAME in existing_indexes:
        print(f"🗑️ Deleting existing index '{INDEX_NAME}'...")
        pc.delete_index(INDEX_NAME)

    print(f"🆕 Creating index '{INDEX_NAME}'...")

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

# ===========================================================
# Load Embedding Model
# ===========================================================
print("🔄 Loading embedding model...")

model = SentenceTransformer("intfloat/e5-large-v2")

print("✅ Model loaded.")

# ===========================================================
# Load CSV
# ===========================================================
print("\n📄 Reading CSV...")

df = pd.read_csv(CSV_PATH)

# Replace NaN with empty strings
df = df.fillna("")

# Convert everything to string
df = df.astype(str)

print("\n📁 CSV Path:")
print(CSV_PATH)

print("\n📌 CSV Columns:")
print(df.columns.tolist())

print("\n📌 First Row:")
print(df.iloc[0].to_dict())

# ===========================================================
# Convert row to searchable text
# ===========================================================
def row_to_string(row):

    return f"""
Industry: {row.get('Industry', '')}
Designation: {row.get('Designation', '')}
Technical_Skills: {row.get('Technical_Skills', '')}
Notable_Projects: {row.get('Notable_Projects', '')}
Mentorship_Area: {row.get('Mentorship_Area', '')}
Current_Company: {row.get('Current_Company', '')}
Interests: {row.get('Interests', '')}
Willing_to_Mentor: {row.get('Willing_to_Mentor', '')}
Years_of_Experience: {row.get('Years_of_Experience', '')}
"""

# ===========================================================
# Create vectors
# ===========================================================
vectors = []

for i, (_, row) in enumerate(df.iterrows()):

    text = row_to_string(row)

    embedding = model.encode(
        "passage: " + text
    ).tolist()

    vector = {
        "id": str(uuid.uuid4()),
        "values": embedding,
        "metadata": row.to_dict()
    }

    # Print ONLY the first vector for debugging
    if i == 0:

        print("\n==============================")
        print("FIRST VECTOR METADATA")
        print("==============================")

        print(vector["metadata"])

        print("\nMetadata Keys:")
        print(vector["metadata"].keys())

        print("==============================\n")

    vectors.append(vector)

# ===========================================================
# Upload
# ===========================================================
if vectors:

    print(f"\n⬆️ Upserting {len(vectors)} vectors...")

    index.upsert(vectors=vectors)

    print("✅ Upsert Complete!")

else:

    print("⚠️ No vectors generated.")