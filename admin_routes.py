# admin_routes.py
from flask import Blueprint, request, jsonify
from config import users_collection, alumni_collection
from auth import token_required
from werkzeug.security import generate_password_hash

admin_api = Blueprint("admin_api", __name__)

@admin_api.route("/admin/add_alumni", methods=["POST"])
@token_required
def add_alumni(current_user):
    if current_user['role'] != 'admin':
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    rollno = data.get('rollno')
    password = data.get('password')

    if not all([name, email, rollno, password]):
        return jsonify({"error": "Missing required fields"}), 400

    rollno_lower = rollno.strip().lower()

    if users_collection.find_one({"_id": rollno_lower}):
        return jsonify({"error": "User with this ID already exists"}), 409

    # --- START OF FIX ---
    # The document must match the structure used by your signup and login logic.
    users_collection.insert_one({
        "_id": rollno_lower,
        "rollno": rollno_lower,
        "password": generate_password_hash(password),
        "role": "alumnus"
    })
    # --- END OF FIX ---
    
    # Also add their details to the main alumni_collection
    alumni_collection.insert_one({
        "Roll_Number": rollno, 
        "Alumni_ID": rollno,
        "Full_Name": name, 
        "Email": email
        # Add other fields as necessary
    })

    return jsonify({"message": f"Alumnus {name} added successfully"}), 201


@admin_api.route("/admin/add_student", methods=["POST"])
@token_required
def add_student(current_user):
    if current_user['role'] != 'admin':
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    rollno = data.get('rollno')
    password = data.get('password')

    if not all([name, email, rollno, password]):
        return jsonify({"error": "Missing required fields"}), 400

    rollno_lower = rollno.strip().lower()

    if users_collection.find_one({"_id": rollno_lower}):
        return jsonify({"error": "User with this ID already exists"}), 409

    # --- START OF FIX ---
    # Correct the structure for the user document.
    users_collection.insert_one({
        "_id": rollno_lower,
        "rollno": rollno_lower,
        "password": generate_password_hash(password),
        "role": "student"
    })
    # --- END OF FIX ---

    return jsonify({"message": f"Student {name} added successfully"}), 201