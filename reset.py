# reset_chat_data.py
from pymongo import MongoClient
from config import mongo_uri  # Import the correct MongoDB URI from your config
# --- IMPORTANT: Make sure these details are correct ---
client = MongoClient(mongo_uri)
DB_NAME = 'alumniDB'

db = client[DB_NAME]

# Collections to be cleared
collections_to_clear = [
    "chat_requests",
    "chat_rooms",
    "chat_room_members",
    "messages"
]

print("--- Starting Chat Data Reset ---")

for coll_name in collections_to_clear:
    collection = db[coll_name]
    result = collection.delete_many({})
    print(f"Cleared '{coll_name}': {result.deleted_count} documents deleted.")

print("\n--- Reset Complete ---")
client.close()