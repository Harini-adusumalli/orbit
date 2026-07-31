# bulk_alumni_signup.py (Corrected Version)
import csv
from pymongo import MongoClient
from werkzeug.security import generate_password_hash
from config import mongo_uri  # Import the correct MongoDB URI from your config
client = MongoClient(mongo_uri)  # Use the correct MongoDB URI from your config
DB_NAME = 'alumniDB'
COLLECTION_NAME = 'users'

db = client[DB_NAME]
users_collection = db[COLLECTION_NAME]

CSV_PATH = 'alumni_demo_dataset_200.csv'
DEFAULT_PASSWORD = 'harini'

# --- START OF FIX: Use the correct column names from your CSV ---
EMAIL_FIELD = 'Email'
NAME_FIELD = 'Full_Name'
# This should be the column that contains 'b2-au-0007', etc.
ROLLNO_FIELD = 'Roll_Number' 
# --- END OF FIX ---

with open(CSV_PATH, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    count = 0
    for row in reader:
        email = row.get(EMAIL_FIELD, "").strip()
        name = row.get(NAME_FIELD, "").strip()
        rollno = row.get(ROLLNO_FIELD, "").strip().lower()

        if not all([email, name, rollno]):
            print(f"Skipping row due to missing data: {row}")
            continue

        if users_collection.find_one({'_id': rollno}):
            print(f"User with ID {rollno} already exists. Skipping.")
            continue

        user_doc = {
            '_id': rollno,
            'rollno': rollno,
            'name': name, # Add name for better notifications
            'email': email,
            'role': 'alumnus',
            'password': generate_password_hash(DEFAULT_PASSWORD)
        }

        users_collection.insert_one(user_doc)
        count += 1
        print(f"Created account for {name} ({rollno})")

    print(f"\nTotal accounts created: {count}")