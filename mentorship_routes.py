# mentorship_routes.py
from flask import Blueprint, request, jsonify
from config import mentorship_posts_collection, mentorship_applications_collection
from auth import token_required
from bson import ObjectId
import datetime

mentorship_api = Blueprint("mentorship_api", __name__)


@mentorship_api.route("/mentorship/posts", methods=["POST"])
@token_required
def create_mentorship_post(current_user):
    if current_user.get('role') != 'alumnus':
        return jsonify({"error": "Only alumni can create mentorship posts"}), 403

    data = request.get_json()
    title = data.get('title')
    description = data.get('description')
    required_skills = data.get('required_skills', []) # Expects a list of strings

    if not all([title, description]):
        return jsonify({"error": "Title and description are required"}), 400

    post_doc = {
        "alumnus_id": current_user['_id'],
        "title": title,
        "description": description,
        "required_skills": required_skills,
        "status": "active", # active, closed
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }
    mentorship_posts_collection.insert_one(post_doc)

    return jsonify({"message": "Mentorship post created successfully", "post_id": str(post_doc['_id'])}), 201


@mentorship_api.route("/mentorship/posts", methods=["GET"])
@token_required
def get_mentorship_posts(current_user):
    # Get all active posts, newest first
    posts = list(mentorship_posts_collection.find({"status": "active"}).sort("created_at", -1))
    for post in posts:
        post['_id'] = str(post['_id'])
        post['created_at'] = post['created_at'].isoformat()
    return jsonify({"posts": posts})


@mentorship_api.route("/mentorship/posts/<post_id>/apply", methods=["POST"])
@token_required
def apply_for_mentorship(current_user, post_id):
    if current_user.get('role') != 'student':
        return jsonify({"error": "Only students can apply for mentorship"}), 403

    try:
        post_obj_id = ObjectId(post_id)
    except Exception:
        return jsonify({"error": "Invalid post_id format"}), 400
        
    post = mentorship_posts_collection.find_one({"_id": post_obj_id})
    if not post or post['status'] != 'active':
        return jsonify({"error": "Mentorship post not found or is no longer active"}), 404

    # Check if user has already applied
    existing_application = mentorship_applications_collection.find_one({
        "post_id": post_obj_id,
        "student_id": current_user['_id']
    })
    if existing_application:
        return jsonify({"error": "You have already applied for this mentorship"}), 409

    application_doc = {
        "post_id": post_obj_id,
        "student_id": current_user['_id'],
        "alumnus_id": post['alumnus_id'],
        "status": "pending", # pending, accepted, rejected
        "applied_at": datetime.datetime.now(datetime.timezone.utc)
    }
    mentorship_applications_collection.insert_one(application_doc)
    
    # Optional: Notify the alumnus via WebSocket (similar to chat requests)
    from app import socketio
    notification_message = f"Student {current_user['_id']} has applied for your mentorship post: '{post['title']}'."
    socketio.emit('new_notification', notification_message, room=post['alumnus_id'])

    return jsonify({"message": "Application submitted successfully"}), 201

