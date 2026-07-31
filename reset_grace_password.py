from pymongo import MongoClient
from werkzeug.security import generate_password_hash
from config import mongo_uri  # Import the correct MongoDB URI from your config
# MongoDB connection
client = MongoClient(mongo_uri)
db = client["alumniDB"]
users = db["users"]

# Target user
rollno = "B2-AU-0007"
new_password = "harini"
new_hash = generate_password_hash(new_password, method='pbkdf2:sha256')

result = users.update_one({"rollno": rollno}, {"$set": {"password": new_hash}})
if result.modified_count:
    print(f"Password for {rollno} reset successfully.")
else:
    print(f"No user updated. Check rollno spelling and case.")
