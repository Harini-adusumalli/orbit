# config.py
import os
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
INDEX_NAME = os.getenv("INDEX_NAME")
MODEL_NAME = os.getenv("MODEL_NAME")
CSV_PATH = os.getenv("CSV_PATH")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
SECRET_KEY = os.getenv("SECRET_KEY")
CREATE_INDEX = os.getenv("CREATE_INDEX") == "True"  # Set to True if you want to delete and recreate the index
from pymongo import MongoClient

mongo_uri = os.getenv("mongo_uri")
# Make sure you've replaced <password> with your real password
client = MongoClient(mongo_uri)

db = client["alumniDB"]
alumni_collection = db["alumni"]
users_collection = db["users"]

# --- ADD THESE NEW COLLECTIONS ---
chat_requests_collection = db["chat_requests"]
notifications_collection = db["notifications"]
chat_rooms_collection = db["chat_rooms"]
chat_room_members_collection = db["chat_room_members"]
messages_collection = db["messages"]
# --- ADD THESE NEW COLLECTIONS FOR PHASE 4 ---
events_collection = db["events"]
event_invites_collection = db["event_invites"]
donations_collection = db["donations"]
mentorship_opportunities_collection = db["mentorship_opportunities"]
mentorship_applications_collection = db["mentorship_applications"]
mentorship_posts_collection = db["mentorship_posts"]


