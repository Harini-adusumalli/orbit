import google.generativeai as genai
from config import GEMINI_API_KEY

# Configure Gemini once at import
genai.configure(api_key=GEMINI_API_KEY)


def query_gemini(prompt: str) -> str:
	"""
	Send a prompt to Gemini and return the response text.
	"""
	try:
		model = genai.GenerativeModel("gemini-2.5-flash")
		response = model.generate_content(prompt)
		return getattr(response, "text", "") or ""
	except Exception as e:
		print(f"Error querying Gemini: {e}")
		return "Sorry, I am unable to process that request right now."



