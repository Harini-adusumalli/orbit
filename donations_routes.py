# donations_routes.py
from flask import Blueprint, request, jsonify
from config import donations_collection
from auth import token_required
import datetime

donations_api = Blueprint("donations_api", __name__)


@donations_api.route("/donations", methods=["POST"])
@token_required
def make_donation(current_user):
    data = request.get_json()
    amount = data.get('amount')

    if not amount or not isinstance(amount, (int, float)) or amount <= 0:
        return jsonify({"error": "A valid positive amount is required"}), 400

    donation_doc = {
        "user_id": current_user['_id'],
        "amount": amount,
        "currency": "USD", # Assuming USD for now
        "status": "completed", # Simulate a successful payment
        "created_at": datetime.datetime.now(datetime.timezone.utc)
    }
    donations_collection.insert_one(donation_doc)

    return jsonify({"message": "Donation successful!", "donation_id": str(donation_doc['_id'])}), 201


@donations_api.route("/donations/history", methods=["GET"])
@token_required
def get_my_donations(current_user):
    donations = list(donations_collection.find({"user_id": current_user['_id']}).sort("created_at", -1))
    for d in donations:
        d['_id'] = str(d['_id'])
        d['created_at'] = d['created_at'].isoformat()
        
    return jsonify({"donations": donations})


@donations_api.route("/donations/all", methods=["GET"])
@token_required
def get_all_donations(current_user):
    if current_user['role'] != 'admin':
        return jsonify({"error": "You are not authorized to view all donations"}), 403

    donations = list(donations_collection.find().sort("created_at", -1))
    for d in donations:
        d['_id'] = str(d['_id'])
        d['created_at'] = d['created_at'].isoformat()
        
    return jsonify({"donations": donations})

