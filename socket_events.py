# socket_events.py
from flask_socketio import SocketIO, join_room, leave_room
from flask import request
from config import messages_collection, users_collection
import jwt
from config import SECRET_KEY
import datetime
from bson import ObjectId

socketio = SocketIO(cors_allowed_origins="*")

user_rooms = {}

@socketio.on('join_chat_room')
def handle_join_chat_room(data):
    token = data.get('token')
    room_id = data.get('room_id')
    if not token or not room_id:
        return

    try:
        token_data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        user_id = token_data['rollno']
        join_room(room_id)
        user_rooms[request.sid] = room_id
        print(f"User {user_id} joined room {room_id}")
    except Exception as e:
        print(f"Failed to join room: {e}")


@socketio.on('send_message')
def handle_send_message(data):
    token = data.get('token')
    room_id = data.get('room_id')
    message_text = data.get('message')

    if not all([token, room_id, message_text]):
        return

    try:
        token_data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        sender_id = token_data['rollno']

        # --- DIAGNOSTIC LOGS START HERE ---
        print(f"--- 1. ATTEMPTING TO SAVE MESSAGE ---")

        room_obj_id = ObjectId(room_id)
        message_doc = {
            "room_id": room_obj_id,
            "sender_id": sender_id,
            "text": message_text,
            "created_at": datetime.datetime.now(datetime.timezone.utc)
        }
        
        print(f"--- 2. DATA TO INSERT: {message_doc}")

        result = messages_collection.insert_one(message_doc)
        
        print(f"--- 3. MONGO SUCCESS! INSERTED ID: {result.inserted_id}")
        # --- DIAGNOSTIC LOGS END HERE ---

        socketio.emit('new_message', {
            'sender_id': sender_id,
            'text': message_text
        }, room=room_id)
        print(f"--- 4. Message emitted to room {room_id}")

    except Exception as e:
        # This will now catch any error during the process
        print(f"!!!!!!!! AN ERROR OCCURRED !!!!!!!!: {e}")


@socketio.on('disconnect')
def handle_disconnect():
    room_id = user_rooms.pop(request.sid, None)
    if room_id:
        leave_room(room_id)
    print(f"Client disconnected: {request.sid}")