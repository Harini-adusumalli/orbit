# app.py
from flask import Flask
from flask_cors import CORS
from socket_events import socketio
import os
# --- STEP 1: Import ALL your blueprints ---
from routes import routes
from chat_routes import chat_api
from profile_routes import profile_api
from donations_routes import donations_api
from event_routes import event_api
from mentorship_routes import mentorship_api
from bot_routes import bot_api
from admin_routes import admin_api

def create_app():
    app = Flask(__name__)
    CORS(app, resources={r"/*": {"origins": "*"}})
    # --- STEP 2: Register ALL your blueprints with the app ---
    app.register_blueprint(routes)
    app.register_blueprint(chat_api)
    app.register_blueprint(profile_api)
    app.register_blueprint(donations_api)
    app.register_blueprint(event_api)
    app.register_blueprint(mentorship_api)
    app.register_blueprint(bot_api)
    app.register_blueprint(admin_api)

    # Initialize socketio with the app instance
    socketio.init_app(app, cors_allowed_origins="*")
    return app

if __name__ == "__main__":
    print("Creating app...")
    app = create_app()
    print("App created successfully!")
    print("Starting server...")

    port = int(os.environ.get("PORT", 5000))

    socketio.run(
        app,
        host="0.0.0.0",
        port=port,
        debug=False
    )