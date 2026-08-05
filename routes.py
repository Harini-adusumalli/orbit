# File: routes.py (Corrected and Final Version)

from flask import Blueprint, request, jsonify
from pinecone_client import query_alumni
from config import users_collection
from gemini_client import query_gemini
import json
import re
import textwrap
# ---------------- Password Validation ----------------
def is_strong_password(password):
    """
    Password must contain:
    - At least 8 characters
    - One uppercase letter
    - One lowercase letter
    - One digit
    - One special character
    """
    return (
        len(password) >= 8
        and re.search(r"[A-Z]", password)
        and re.search(r"[a-z]", password)
        and re.search(r"\d", password)
        and re.search(r"[!@#$%^&*(),.?\":{}|<>]", password)
    )
# --- NEW IMPORTS for security and JWTs ---
from werkzeug.security import generate_password_hash, check_password_hash
from config import SECRET_KEY  # Import the secret key from our new auth file
import jwt
import datetime

routes = Blueprint("routes", __name__)

# Predefined options and canned responses. Users must pick one of these options — free-text questions are not allowed.
OPTIONS = {
    "1": {"key": "search_alumni", "label": "Search alumni", "response": "Open Search > enter name or roll number > tap a profile from results."},
    "2": {"key": "send_chat_request", "label": "Send chat request", "response": "Open an alumni profile > tap 'Send Chat Request' > wait for approval in Notifications."},
    "3": {"key": "view_chats", "label": "View active chats", "response": "Open Chats > select a chat to view messages. Use the back button to return to chat list."},
    "4": {"key": "notifications", "label": "Notifications", "response": "Open Notifications from the top-right bell icon to see new requests and messages."},
    "5": {"key": "profile", "label": "Profile", "response": "Open Profile > edit your details > save. Your roll number is your unique ID."},
    "6": {"key": "signup_login", "label": "Sign up / Login", "response": "On the Welcome screen use Sign up to register (roll number/password). Use Login with your roll number and password."}
}

MENU_TEXT = "Hi — I'm Orbit Assistant. Choose one: 1) Search alumni 2) Send chat request 3) View chats 4) Notifications 5) Profile 6) Sign up / Login. Reply with the option number."

# Machine-readable menu endpoint (UI can fetch this to build buttons)
@routes.route("/menu", methods=["GET"])
def get_menu():
    print("ROUTES.PY LOADED")
    """Return the menu and options in a JSON structure suitable for UI consumption."""
    options_list = []
    for opt_id, opt in OPTIONS.items():
        options_list.append({
            "id": opt_id,
            "key": opt.get("key"),
            "label": opt.get("label"),
        })

    return jsonify({
        "menu_text": MENU_TEXT,
        "options": options_list
    }), 200



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

        # 1. Check for option selection (enforce menu-driven interaction)
        selected_option = data.get("option") or data.get("selected_option")
        # Also detect if the user replied with a plain option number as the last message
        last_user_text = None
        try:
            last = history[-1]
            last_user_text = (last.get("parts") or "").strip()
            if isinstance(last_user_text, list):
                last_user_text = " ".join(str(p) for p in last_user_text)
            if last_user_text and last_user_text.isdigit() and last_user_text in OPTIONS:
                selected_option = last_user_text
        except Exception:
            pass

        # If no option selected and the user greeting, return the menu
        if not selected_option:
            # detect simple greetings and return menu
            if last_user_text and last_user_text.lower() in ("hi", "hello", "hey"):
                return jsonify({"response": MENU_TEXT}), 200
            # If incoming message is not an allowed option, force the user to choose
            return jsonify({"response": "Please choose an option from the menu: " + MENU_TEXT}), 200

        # If option provided, return the canned response
        opt = OPTIONS.get(str(selected_option))
        if opt:
            return jsonify({"response": opt["response"]}), 200

        # Fallback: if option key is unknown, prompt menu
        return jsonify({"response": "Unknown option. " + MENU_TEXT}), 200

        # All chat interactions are handled above via the predefined OPTIONS and menu.
        # This endpoint no longer sends user queries to the LLM. If execution reaches here, return a generic instruction.
        return jsonify({"response": "Please choose one of the options from the menu: " + MENU_TEXT}), 200

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
        return jsonify({
            "error": "Roll number, password, and role are required"
        }), 400

    # -------- Password Strength Validation --------
    if not is_strong_password(password):
        return jsonify({
            "error": "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character."
        }), 400

    # Normalize roll number
    rollno_lower = rollno.strip().lower()

    # Check if user already exists
    if users_collection.find_one({"_id": rollno_lower}):
        return jsonify({
            "error": "User with this roll number already exists"
        }), 409

    # Hash the password
    hashed_password = generate_password_hash(
        password,
        method="pbkdf2:sha256"
    )

    # Store user
    users_collection.insert_one({
        "_id": rollno_lower,
        "rollno": rollno_lower,
        "password": hashed_password,
        "role": role
    })

    return jsonify({
        "message": f"{role.capitalize()} registered successfully"
    }), 201

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