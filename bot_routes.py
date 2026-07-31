# bot_routes.py
from flask import Blueprint, request, jsonify
from auth import token_required
from pinecone_client import query_alumni
from gemini_client import query_gemini
import json

bot_api = Blueprint("bot_api", __name__)

@bot_api.route("/bot-chat", methods=["POST"])
@token_required
def bot_chat_route(current_user):
    data = request.get_json()
    chat_history = data.get("history", []) # Expects a list of {"role": "user/model", "parts": [{"text": "..."}]}
    new_question = data.get("question", "")

    if not new_question:
        return jsonify({"error": "A new question is required"}), 400

    # --- Step 1: Use the new question to search for relevant alumni (RAG) ---
    # We use the most recent question as the primary query for semantic search
    try:
        search_results = query_alumni(new_question, top_k=3) # Fetch top 3 most relevant alumni
        context_str = json.dumps(search_results)
    except Exception as e:
        print(f"Error during Pinecone query in bot chat: {e}")
        search_results = []
        context_str = "[]"
    
    # --- Step 2: Construct a detailed prompt for the Gemini LLM ---
    # This prompt provides the full conversation history and the new "context" from our search
    prompt = f"""
You are "Orbit Bot", a helpful AI assistant for the Alumni Connect platform.
Your goal is to answer user questions about alumni.
Use the provided CONTEXT from a database search to answer the user's question.
If the context does not contain the answer, say that you don't have that information.
Do not make up information. Be friendly and conversational.

CONVERSATION HISTORY:
{json.dumps(chat_history)}

CONTEXT FROM ALUMNI DATABASE:
{context_str}

Based on the history and the new context, answer this new question:
NEW QUESTION: "{new_question}"
"""

    # --- Step 3: Call Gemini API ---
    try:
        ai_response = query_gemini(prompt)
        return jsonify({"response": ai_response})
    except Exception as e:
        print(f"Error querying Gemini in bot chat: {e}")
        return jsonify({"error": "An error occurred while communicating with the AI model."}), 500

