# chat_routes.py
from flask import Blueprint, request, jsonify
from config import (
    chat_requests_collection, 
    notifications_collection, 
    chat_rooms_collection,
    chat_room_members_collection,
    messages_collection,
    users_collection,
    alumni_collection 
)
from auth import token_required
from bson import ObjectId
import datetime

chat_api = Blueprint("chat_api", __name__)


@chat_api.route("/chat-requests/send", methods=["POST"])
@token_required
def send_chat_request(current_user):
    from socket_events import socketio

    print("\n========== CHAT REQUEST ==========")
    print("Current User:")
    print(current_user)

    data = request.get_json()
    print("\nReceived JSON:")
    print(data)

    recipient_profile_id = data.get("alumni_id")

    if not recipient_profile_id:
        return jsonify({"error": "alumni_id is required"}), 400

    # Find alumni profile
    recipient_profile = alumni_collection.find_one({
        "Alumni_ID": recipient_profile_id
    })

    print("\nRecipient Profile:")
    print(recipient_profile)

    if not recipient_profile:
        return jsonify({
            "error": "Recipient profile not found"
        }), 404

    # Get roll number from alumni profile
    recipient_user_id_from_profile = recipient_profile.get("Roll_Number")

    print("\nRoll Number from Profile:")
    print(recipient_user_id_from_profile)

    if not recipient_user_id_from_profile:
        return jsonify({
            "error": "Recipient profile is missing Roll_Number"
        }), 404

    # Find corresponding user account
    recipient_user = users_collection.find_one({
        "_id": {
            "$regex": f"^{recipient_user_id_from_profile}$",
            "$options": "i"
        }
    })

    print("\nRecipient User:")
    print(recipient_user)

    if not recipient_user:
        return jsonify({
            "error": "Recipient not found in users collection"
        }), 404

    recipient_user_id = recipient_user["_id"]

    # Don't allow chatting with yourself
    if current_user["_id"] == recipient_user_id:
        return jsonify({
            "error": "You cannot send a chat request to yourself"
        }), 400

    # Check for existing pending/accepted request
    existing_request = chat_requests_collection.find_one({
        "sender_id": current_user["_id"],
        "recipient_id": recipient_user_id,
        "status": {
            "$in": ["pending", "accepted"]
        }
    })

    if existing_request:
        return jsonify({
            "error": "A pending or accepted chat request already exists."
        }), 409

    # Create request
    request_doc = {
        "sender_id": current_user["_id"],
        "recipient_id": recipient_user_id,
        "status": "pending",
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }

    print("\nSaving Chat Request:")
    print(request_doc)

    result = chat_requests_collection.insert_one(request_doc)

    request_doc["_id"] = result.inserted_id

    print("Inserted Request ID:")
    print(result.inserted_id)

    # Notification
    notification_doc = {
        "user_id": recipient_user_id,
        "message": f"You have a new chat request from {current_user.get('name', current_user['_id'])}.",
        "type": "chat_request",
        "is_read": False,
        "related_id": str(result.inserted_id),
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }

    notifications_collection.insert_one(notification_doc)

    socketio.emit(
        "new_notification",
        notification_doc["message"],
        room=recipient_user_id
    )

    print("\n✅ Chat Request Sent Successfully")

    return jsonify({
        "message": "Chat request sent successfully"
    }), 201
@chat_api.route("/chat-requests/<request_id>/<action>", methods=["POST"])
@token_required
def respond_to_chat_request(current_user, request_id, action):
    from socket_events import socketio

    if action not in ["accept", "reject"]:
        return jsonify({"error": "Invalid action"}), 400

    try:
        req_obj_id = ObjectId(request_id)
    except Exception:
        return jsonify({"error": "Invalid request_id format"}), 400

    chat_request = chat_requests_collection.find_one({"_id": req_obj_id})

    if not chat_request or chat_request.get('recipient_id') != current_user['_id']:
        return jsonify({"error": "Chat request not found or you are not authorized"}), 404
    
    if chat_request['status'] != 'pending':
        return jsonify({"error": "This request has already been responded to"}), 409

    new_status = "accepted" if action == "accept" else "rejected"
    chat_requests_collection.update_one({"_id": req_obj_id}, {"$set": {"status": new_status}})

    sender_id = chat_request['sender_id']
    
    if new_status == "accepted":
        room_doc = {
            "created_at": datetime.datetime.now(datetime.timezone.utc),
            "members": [sender_id, current_user['_id']]
        }
        room_result = chat_rooms_collection.insert_one(room_doc)
        
        chat_room_members_collection.insert_many([
            {"room_id": room_result.inserted_id, "user_id": sender_id},
            {"room_id": room_result.inserted_id, "user_id": current_user['_id']}
        ])

    notification_doc = {
        "user_id": sender_id,
        "message": f"Your chat request with {current_user.get('name', current_user['_id'])} has been {new_status}.",
        "type": "chat_response",
        "is_read": False,
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }
    notifications_collection.insert_one(notification_doc)
    socketio.emit('new_notification', notification_doc['message'], room=sender_id)

    return jsonify({"message": f"Request {new_status}"}), 200


@chat_api.route("/chats", methods=["GET"])
@token_required
def get_user_chats(current_user):
    user_id = current_user['_id']
    
    memberships = list(chat_room_members_collection.find({"user_id": user_id}))
    room_ids = [m['room_id'] for m in memberships]
    rooms = list(chat_rooms_collection.find({"_id": {"$in": room_ids}}))

    active_chats = []
    for room in rooms:
        other_member_id = next((member for member in room['members'] if member != user_id), None)
        room_name = "Unknown User"
        if other_member_id:
            other_user = users_collection.find_one({"_id": other_member_id})
            if other_user:
                room_name = other_user.get('name', other_member_id)
        last_message = messages_collection.find_one(
        {"room_id": room["_id"]},
        sort=[("created_at", -1)]
    )

        active_chats.append({
            "room_id": str(room["_id"]),
            "recipient_name": room_name,
            "last_message": last_message["text"] if last_message else "Start chatting..."
        })

    pending_requests_cursor = chat_requests_collection.find({
        "recipient_id": user_id,
        "status": "pending"
    })
    
    pending_requests = []
    for req in pending_requests_cursor:
        sender_user = users_collection.find_one({"_id": req['sender_id']})
        sender_name = sender_user.get('name', req['sender_id']) if sender_user else "Unknown User"
        pending_requests.append({
            "id": str(req['_id']),
            "sender_name": sender_name
        })
    print("\n========== ACTIVE CHATS ==========")
    print(active_chats)

    print("\n========== PENDING REQUESTS ==========")
    print(pending_requests)
    return jsonify({
        "active_chats": active_chats,
        "pending_requests": pending_requests
    })


@chat_api.route("/chats/<room_id>/messages", methods=["GET"])
@token_required
def get_messages_for_room(current_user, room_id):
    try:
        room_obj_id = ObjectId(room_id)
    except Exception:
        return jsonify({"error": "Invalid room_id format"}), 400

    membership = chat_room_members_collection.find_one({
        "room_id": room_obj_id,
        "user_id": current_user['_id']
    })
    if not membership:
        return jsonify({"error": "You are not a member of this chat room"}), 403

    messages_cursor = messages_collection.find({"room_id": room_obj_id}).sort("created_at", 1)

    messages_list = []
    for msg in messages_cursor:
        messages_list.append({
            "_id": str(msg['_id']),
            "room_id": str(msg['room_id']),
            "sender_id": msg['sender_id'],
            "text": msg['text'],
            "created_at": msg['created_at'].isoformat()
        })

    return jsonify({"messages": messages_list})