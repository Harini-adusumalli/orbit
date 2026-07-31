import pandas as pd
from pymongo import MongoClient

from config import mongo_uri

client = MongoClient(mongo_uri)

db = client["alumniDB"]
alumni_collection = db["alumni"]

df = pd.read_csv("alumni_demo_dataset_200.csv")

records = df.to_dict("records")

alumni_collection.delete_many({})   # optional: clears existing data

alumni_collection.insert_many(records)

print(f"Imported {len(records)} alumni records successfully!")