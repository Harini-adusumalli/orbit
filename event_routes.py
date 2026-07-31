# event_routes.py
from flask import Blueprint, request, jsonify
from config import (
    events_collection,
    event_invites_collection,
    notifications_collection,
    users_collection
)
from auth import token_required
from bson import ObjectId
import datetime

event_api = Blueprint("event_api", __name__)


@event_api.route("/events", methods=["POST"])
@token_required
def create_event(current_user):
    from app import socketio

    if current_user['role'] != 'admin':
        return jsonify({"error": "Only admins can create events"}), 403

    data = request.get_json()
    title = data.get('title')
    description = data.get('description')
    event_date = data.get('event_date') # e.g., "2025-12-25T14:00:00Z"
    alumni_ids_to_invite = data.get('alumni_ids', [])

    if not all([title, description, event_date]):
        return jsonify({"error": "Title, description, and event_date are required"}), 400

    event_doc = {
        "title": title,
        "description": description,
        "event_date": event_date,
        "created_by": current_user['_id'],
        "speakers": [],
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }
    event_result = events_collection.insert_one(event_doc)

    for alumni_id in alumni_ids_to_invite:
        invite_doc = {
            "event_id": event_result.inserted_id,
            "alumni_id": alumni_id,
            "status": "pending",
            "created_at": datetime.datetime.now(datetime.timezone.utc)
        }
        event_invites_collection.insert_one(invite_doc)
        
        notification_doc = {
            "user_id": alumni_id,
            "message": f"You have been invited to speak at the event: '{title}'.",
            "type": "event_invite",
            "is_read": False,
            "related_id": str(invite_doc['_id']),
            "created_at": datetime.datetime.now(datetime.timezone.utc)
        }
        notifications_collection.insert_one(notification_doc)
        socketio.emit('new_notification', notification_doc['message'], room=alumni_id)

    return jsonify({"message": "Event created and invites sent"}), 201


@event_api.route("/event-invites/<invite_id>/<action>", methods=["POST"])
@token_required
def respond_to_event_invite(current_user, invite_id, action):
    from app import socketio

    if action not in ["accept", "reject"]:
        return jsonify({"error": "Invalid action"}), 400

    try:
        invite_obj_id = ObjectId(invite_id)
    except Exception:
        return jsonify({"error": "Invalid invite_id format"}), 400

    invite = event_invites_collection.find_one({"_id": invite_obj_id})

    if not invite or invite['alumni_id'] != current_user['_id']:
        return jsonify({"error": "Invite not found or you are not authorized"}), 404

    new_status = "accepted" if action == "accept" else "rejected"
    event_invites_collection.update_one({"_id": invite_obj_id}, {"$set": {"status": new_status}})

    event = events_collection.find_one({"_id": invite['event_id']})
    
    if action == 'accept':
        events_collection.update_one(
            {"_id": invite['event_id']},
            {"$addToSet": {"speakers": current_user['_id']}}
        )

    admin_id = event.get('created_by')
    if admin_id:
        notification_doc = {
            "user_id": admin_id,
            "message": f"Alumnus {current_user['_id']} has {new_status} your invitation to '{event['title']}'.",
            "type": "event_response", "is_read": False,
            "created_at": datetime.datetime.now(datetime.timezone.utc)
        }
        notifications_collection.insert_one(notification_doc)
        socketio.emit('new_notification', notification_doc['message'], room=admin_id)

    return jsonify({"message": f"Invite {new_status}"}), 200


@event_api.route("/events", methods=["GET"])
def list_events():
    events = list(events_collection.find().sort("event_date", 1))
    for event in events:
        event['_id'] = str(event['_id'])
    return jsonify({"events": events})

