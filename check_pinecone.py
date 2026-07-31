from pinecone import Pinecone
from config import PINECONE_API_KEY, INDEX_NAME
import time

print("--- Pinecone Sanity Check ---")

try:
    # --- 1. Initialize Pinecone ---
    pc = Pinecone(api_key=PINECONE_API_KEY)
    print(f"✅ Pinecone initialized.")

    # --- 2. Connect to the index ---
    index = pc.Index(INDEX_NAME)
    print(f"✅ Connected to index '{INDEX_NAME}'.")
    
    # --- 3. Check stats before upsert ---
    stats_before = index.describe_index_stats()
    print(f"📊 Stats before upsert: {stats_before}")

    # --- 4. Create and upsert ONE dummy vector ---
    print("⬆️  Attempting to upsert a single dummy vector...")
    dummy_vector = ([0.1] * 1024) # A 1024-dimensional vector
    index.upsert(
        vectors=[("dummy-test-vector-1", dummy_vector, {"status": "test"})]
    )
    print("✅ Upsert command sent successfully.")

    # --- 5. Wait and check stats after ---
    print("🕒 Waiting 15 seconds for index to update...")
    time.sleep(15)
    
    stats_after = index.describe_index_stats()
    print(f"📊 Stats after upsert: {stats_after}")

    if stats_after.get('total_vector_count', 0) > stats_before.get('total_vector_count', 0):
        print("\n🎉 SUCCESS: The vector count increased. Your index is working correctly!")
    else:
        print("\n⚠️ FAILURE: The vector count did not increase. There might be an issue with your index or API key.")

except Exception as e:
    print(f"\n❌ An error occurred: {e}")