# delete_alumni_users.py
from pymongo import MongoClient
from config import mongo_uri  # Import the correct MongoDB URI from your config
# --- IMPORTANT: Make sure these details are correct ---
client = MongoClient(mongo_uri)
DB_NAME = 'alumniDB'
COLLECTION_NAME = 'users'

db = client[DB_NAME]
users_collection = db[COLLECTION_NAME]

# This is the query that finds all users with the role 'alumnus'
query = {"role": "alumnus"}

# --- Deletion ---
print("Finding alumni accounts to delete...")
result = users_collection.delete_many(query)

print(f"\nDeletion complete.")
print(f"Total alumni accounts deleted: {result.deleted_count}")

client.close()