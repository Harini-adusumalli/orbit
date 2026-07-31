# profile_routes.py
from flask import Blueprint, request, jsonify
from config import alumni_collection
from auth import token_required
from pinecone import Pinecone
from config import PINECONE_API_KEY, INDEX_NAME
from model import get_embedding

profile_api = Blueprint("profile_api", __name__)

pc = Pinecone(api_key=PINECONE_API_KEY)
index = pc.Index(INDEX_NAME)

def profile_to_string(profile):
    """Helper function to convert a profile document to a string for embedding."""
    return f"""Industry: {profile.get('Industry', '')}
Designation: {profile.get('Designation', '')}
Technical_Skills: {profile.get('Technical_Skills', '')}
Notable_Projects: {profile.get('Notable_Projects', '')}
Mentorship_Area: {profile.get('Mentorship_Area', '')}
Current_Company: {profile.get('Current_Company', '')}
Interests: {profile.get('Interests', '')}
Willing_to_Mentor: {profile.get('Willing_to_Mentor', '')}
Years_of_Experience: {profile.get('Years_of_Experience', '')}
"""

@profile_api.route("/profile", methods=["GET"])
@token_required
def get_my_profile(current_user):
    # The 'current_user' object contains the user's unique ID (e.g., "alum-185")
    user_id = current_user['_id']

    # --- REFINED CODE ---
    # Perform a case-insensitive search to find the alumni profile.
    # This matches "alum-185" with "ALUM-185" in the database.
    profile_data = alumni_collection.find_one(
        {"Roll_Number": {"$regex": f"^{user_id}$", "$options": "i"}}
    )
    # --- END REFINED CODE ---

    if not profile_data:
        return jsonify({"error": f"Alumni profile not found for user ID: {user_id}"}), 404
        
    profile_data['_id'] = str(profile_data['_id'])
    return jsonify(profile_data)


@profile_api.route("/profile", methods=["PUT"])
@token_required
def update_my_profile(current_user):
    data = request.get_json()
    
    updatable_fields = [
        'Current_Company', 'Designation', 'Industry', 'Years_of_Experience',
        'Technical_Skills', 'Soft_Skills', 'Interests', 'Willing_to_Mentor',
        'Mentorship_Area', 'Notable_Projects', 'LinkedIn_URL'
    ]
    
    update_data = {key: data[key] for key in data if key in updatable_fields}

    if not update_data:
        return jsonify({"error": "No valid fields provided for update"}), 400

    # --- REFINED CODE ---
    # Use a case-insensitive query for the update as well to ensure consistency.
    user_id = current_user['_id']
    filter_query = {"Roll_Number": {"$regex": f"^{user_id}$", "$options": "i"}}
    
    result = alumni_collection.update_one(
        filter_query,
        {"$set": update_data}
    )
    # --- END REFINED CODE ---

    if result.matched_count == 0:
        return jsonify({"error": "Profile not found for this user"}), 404

    try:
        updated_profile = alumni_collection.find_one(filter_query)
        
        if updated_profile:
            profile_text = profile_to_string(updated_profile)
            new_vector = get_embedding("passage: " + profile_text)
            vector_id = updated_profile.get("Alumni_ID")

            if vector_id:
                updated_profile.pop('_id', None)
                index.upsert(vectors=[(vector_id, new_vector, updated_profile)])
                print(f"Successfully updated vector for {vector_id} in Pinecone.")
            else:
                print(f"Warning: Could not find Alumni_ID for user {user_id} to update Pinecone.")

    except Exception as e:
        print(f"Error updating Pinecone vector for user {user_id}: {e}")
        return jsonify({"message": "Profile updated in database, but failed to update search index."}), 500

    return jsonify({"message": "Profile updated successfully"}), 200