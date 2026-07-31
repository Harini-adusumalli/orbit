# test_mongo_connection.py
from pymongo.errors import ConnectionFailure
from config import client # Import the 'client' object from your config file

def test_connection():
    """
    Tests the connection to the MongoDB server.
    """
    print("--- Testing MongoDB Connection ---")
    try:
        # The ismaster command is cheap and does not require auth.
        client.admin.command('ismaster')
        print("✅ SUCCESS: MongoDB connection established successfully.")
        print("Your application is correctly configured to communicate with the database.")
    except ConnectionFailure as e:
        print("❌ FAILED: Could not connect to MongoDB.")
        print("\nCommon reasons for failure:")
        print("1. Incorrect Password: Double-check the password in your MONGO_URI in config.py.")
        print("2. IP Access List: Ensure your current IP address is whitelisted in MongoDB Atlas.")
        print("3. Firewall: A local or network firewall might be blocking the connection.")
        print(f"\nError details: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    test_connection()
