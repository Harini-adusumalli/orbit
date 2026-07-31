# verify_pinecone.py (Corrected Version)

from pinecone import Pinecone
from config import PINECONE_API_KEY, INDEX_NAME

print("--- Pinecone Verification (v2) ---")

try:
    pc = Pinecone(api_key=PINECONE_API_KEY)
    index = pc.Index(INDEX_NAME)
    print(f"✅ Connected to index '{INDEX_NAME}'.")

    VECTOR_ID_TO_FETCH = "dummy-test-vector-1"
    
    print(f"🔎 Attempting to fetch vector with ID: '{VECTOR_ID_TO_FETCH}'...")
    
    fetch_response = index.fetch(ids=[VECTOR_ID_TO_FETCH])
    
    print(f"🔍 Fetch response received.")

    # --- FIX: Access data using dot notation (object.vectors) instead of .get() ---
    if fetch_response.vectors and VECTOR_ID_TO_FETCH in fetch_response.vectors:
        print("\n🎉 SUCCESS! The test vector was successfully retrieved from the index.")
        print("This confirms your Pinecone index is fully operational.")
        
        # --- FIX: Access the specific vector data and its metadata using dot notation ---
        retrieved_vector = fetch_response.vectors[VECTOR_ID_TO_FETCH]
        print(f"Retrieved Metadata: {retrieved_vector.metadata}")
    else:
        print("\n⚠️ Vector not found. The index might still be updating or the upsert failed.")
        print("Full Response:", fetch_response)

except Exception as e:
    print(f"\n❌ An error occurred: {e}")