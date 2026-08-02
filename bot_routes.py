# bot_routes.py
from flask import Blueprint, request, jsonify
from auth import token_required
from pinecone_client import query_alumni
from gemini_client import query_gemini
import json
import textwrap

bot_api = Blueprint("bot_api", __name__)

@bot_api.route("/bot-chat", methods=["POST"])
@token_required
def bot_chat_route(current_user):
    data = request.get_json()
    chat_history = data.get("history", [])

    # Enforce menu-driven interaction: only accept predefined options
    selected_option = data.get("option") or data.get("selected_option")
    last_user_text = None
    try:
        last = chat_history[-1]
        last_user_text = (last.get("parts") or "").strip()
        if isinstance(last_user_text, list):
            last_user_text = " ".join(str(p) for p in last_user_text)
        if last_user_text and last_user_text.isdigit() and last_user_text in OPTIONS:
            selected_option = last_user_text
    except Exception:
        pass

    if not selected_option:
        # greeting -> return menu
        if last_user_text and last_user_text.lower() in ("hi", "hello", "hey"):
            return jsonify({"response": MENU_TEXT})
        return jsonify({"response": "Please choose an option from the menu: " + MENU_TEXT})

    opt = OPTIONS.get(str(selected_option))
    if opt:
        return jsonify({"response": opt["response"]})

    return jsonify({"response": "Unknown option. " + MENU_TEXT}), 200

    # If we reach here the request would have been handled above

    # We use the most recent question as the primary query for semantic search
    try:
        search_results = query_alumni(new_question, top_k=3) # Fetch top 3 most relevant alumni
        context_str = json.dumps(search_results)
    except Exception as e:
        print(f"Error during Pinecone query in bot chat: {e}")
        search_results = []
        context_str = "[]"
    
    # --- Step 2: Format the conversation history for the AI ---
    formatted_history = ""
    for message in chat_history:
        role = message.get("role", "user").replace("model", "assistant").capitalize()
        parts = message.get("parts", "")
        if isinstance(parts, list):
            parts = " ".join(str(part) for part in parts)
        formatted_history += f"{role}: {parts}\n"

    user_message = new_question

    # --- Step 3: Construct a detailed prompt for the Gemini LLM ---
    # This prompt provides the full conversation history and the new "context" from our search
    prompt = textwrap.dedent(f"""
        You are Orbit Assistant, the in-app help assistant for the Orbit Alumni Connect app.
        Your goal: help users use the app's alumni search and chat features, using any provided search context when relevant.

        STRICT OUTPUT RULES (follow exactly):
        - ONLY answer about app usage or the exact search context provided in the {context_str} block. Do NOT invent facts about people, mentors, hiring, or internal teams.
        - Keep responses concise: maximum 50 words and at most 3 short sentences.
        - For greetings ("hi","hello","hey"): reply with one friendly line and a short numbered menu (max 5 items).
        - When referencing search context, only use fields present in the context; do not add details.
        - For actions, give 1–3 short steps (each <12 words).
        - If required info is missing, say "I don't have that detail — try X" and suggest a next step.
        - Output a single plain-text reply only (no JSON, no extended marketing or team descriptions).

        Relevant search context (if any):
        ---
        {context_str}
        ---

        Conversation history (most recent first):
        ---
        {formatted_history}
        ---

        Now produce a single concise response to the latest user message following the rules above.
    """)

    # --- Step 4: Call Gemini API ---
    try:
        ai_response = query_gemini(prompt)
        return jsonify({"response": ai_response})
    except Exception as e:
        print(f"Error querying Gemini in bot chat: {e}")
        return jsonify({"error": "An error occurred while communicating with the AI model."}), 500

