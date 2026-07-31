# File: routes.py (Corrected and Final Version)

from flask import Blueprint, request, jsonify
from pinecone_client import query_alumni
from config import users_collection
from gemini_client import query_gemini
import json
import re

# --- NEW IMPORTS for security and JWTs ---
from werkzeug.security import generate_password_hash, check_password_hash
from config import SECRET_KEY  # Import the secret key from our new auth file
import jwt
import datetime

routes = Blueprint("routes", __name__)


# --- Your existing /query and /chat routes are fine, they remain unchanged ---

@routes.route("/query", methods=["POST"])
def query_route():
    # ... (no changes needed here)
    try:
        data = request.get_json()
        user_query = data.get("query", "").strip()

        if not user_query:
            return jsonify({"error": "Query text is required"}), 400

        results = query_alumni(user_query)
        
        return jsonify({
            "query": user_query,
            "results": results
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# In routes.py

@routes.route("/chat", methods=["POST"])
def chat_route():
    try:
        data = request.get_json()
        
        # The 'results' field from your Flutter app contains the chat history
        history = data.get("results", [])
        if not history:
            return jsonify({"error": "No query or history provided"}), 400

        # --- START OF NEW LOGIC ---

        # 1. Format the conversation history for the AI
        # We'll make it look like a script for the AI to read.
        formatted_history = ""
        for message in history:
            # Get the role ('user' or 'model') and the text part
            role = message.get("role", "user").replace("model", "assistant").capitalize()
            parts = message.get("parts", "")
            formatted_history += f"{role}: {parts}\n"

        # 2. Create the new, more intelligent prompt
        prompt = f"""
        You are "Orbit Assistant", a helpful, wise, and encouraging career advisor for university students and alumni. Your goal is to provide thoughtful guidance.

        Here is the conversation history so far:
        ---
        {formatted_history}
        ---

        Based on the full conversation history, provide a helpful and relevant response to the user's latest message.
        - If the user asks for advice (e.g., "what qualities should I look for in a mentor?"), give a thoughtful, list-based answer.
        - If the user asks for an opinion on a company or mentor, provide a balanced view based on general knowledge.
        - If you don't know the answer, say so politely and suggest how the user might find the information.
        - Keep your answers encouraging and easy to understand.
        """
        
        # 3. Send the new prompt to the AI
        response_text = query_gemini(prompt)
        
        return jsonify({"response": response_text}), 200

        # --- END OF NEW LOGIC ---

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# --- UPDATED /signup route ---
@routes.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()
    rollno = data.get("rollno")
    password = data.get("password")
    role = data.get("role")

    if not all([rollno, password, role]):
        return jsonify({"error": "Roll number, password, and role are required"}), 400

    # Convert roll number to lowercase for consistency
    rollno_lower = rollno.lower()

    if users_collection.find_one({"_id": rollno_lower}):
        return jsonify({"error": "User with this roll number already exists"}), 409

    hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

    users_collection.insert_one({
        "_id": rollno_lower,
        "rollno": rollno_lower,
        "password": hashed_password,
        "role": role
    })

    return jsonify({"message": f"{role.capitalize()} registered successfully"}), 201


# --- UPDATED /login route ---
# --- CORRECTED /login route ---
@routes.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    rollno = data.get("rollno")
    password = data.get("password")

    # Step 1: Check if the required fields are present.
    if not rollno or not password:
        return jsonify({"error": "Roll number and password are required"}), 400

    # Step 2: If fields are present, proceed with authentication logic.
    # This block is now correctly placed to run AFTER the initial check.
    try:
        # Normalize the roll number to lowercase, just like in signup.
        rollno_norm = rollno.strip().lower()
        
        # Find the user in the database.
        user = users_collection.find_one({"_id": rollno_norm})

        # Step 3: Check if a user was found AND if the password matches.
        # Combining these checks is more secure and efficient.
        if not user or not check_password_hash(user['password'], password):
            return jsonify({"error": "Invalid credentials"}), 401

        # Step 4: If everything is correct, create and return the JWT.
        token = jwt.encode({
            'rollno': user['_id'], # Use the consistent _id field
            'role': user['role'],
            'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
        }, SECRET_KEY, algorithm="HS256")

        return jsonify({
            "message": "Login successful",
            "token": token,
            "role": user['role'],
            "rollno": user['rollno']
        }), 200

    except Exception as e:
        # A general error handler for unexpected issues.
        print(f"An error occurred during login: {e}")
        return jsonify({"error": "An internal server error occurred"}), 500