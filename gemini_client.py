from config import (
    GEMINI_API_KEY,
    USE_GEMINI_API,
    LOCAL_LLM_MODEL,
    LOCAL_LLM_DEVICE,
    LOCAL_LLM_MAX_TOKENS,
    LOCAL_LLM_TEMPERATURE,
)

import re

try:
    import google.generativeai as genai
except ImportError:
    genai = None

# Use a cached local pipeline when available.
_local_pipeline = None


def _can_use_gemini_api() -> bool:
    return USE_GEMINI_API and GEMINI_API_KEY and genai is not None


def _query_gemini(prompt: str) -> str:
    if genai is None:
        raise RuntimeError("google.generativeai is not installed. Install it to use Gemini API.")

    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(prompt)
    return getattr(response, "text", "") or ""


def _load_local_pipeline():
    global _local_pipeline
    if _local_pipeline is not None:
        return _local_pipeline

    if not LOCAL_LLM_MODEL:
        raise RuntimeError(
            "No local model configured. Set LOCAL_LLM_MODEL in your environment to use a local LLM."
        )

    try:
        from transformers import pipeline
        import torch
    except ImportError as e:
        raise RuntimeError(
            "Local LLM support requires the 'transformers' and 'torch' packages."
        ) from e

    device = -1
    device_str = LOCAL_LLM_DEVICE.lower()
    if device_str == "cuda":
        device = 0
    elif device_str == "mps":
        device = 0

    pipeline_kwargs = {"device": device}
    if device_str in ("cuda", "mps"):
        pipeline_kwargs["torch_dtype"] = torch.float16

    _local_pipeline = pipeline(
        "text-generation",
        LOCAL_LLM_MODEL,
        **pipeline_kwargs,
    )
    return _local_pipeline


def _query_local_model(prompt: str) -> str:
    """Query the local transformers pipeline with safer, deterministic settings and post-process output.

    Uses greedy decoding (do_sample=False, temperature=0.0) to reduce "thinking" tokens, and truncates/cleans
    repeated or chain-of-thought text. Returns a concise single reply.
    """
    pipeline = _load_local_pipeline()

    # Deterministic / low-entropy generation to avoid internal 'thinking' and repetition
    gen_kwargs = {
        "max_new_tokens": int(LOCAL_LLM_MAX_TOKENS or 200),
        "do_sample": False,
        "temperature": 0.0,
        "top_k": 1,
        "top_p": 1.0,
        "repetition_penalty": 1.1,
        "return_full_text": False,
    }

    outputs = pipeline(prompt, **gen_kwargs)

    if not outputs or not isinstance(outputs, list):
        return ""

    text = outputs[0].get("generated_text", "").strip()

    # Post-processing: remove explicit internal-thinking phrases
    text = re.sub(r"\b(I think|I believe|I'm thinking|I'm not sure|thinking)\b[\w\W]*?$", "", text, flags=re.I)

    # Truncate at first double newline or common separator to avoid appended marketing or examples
    for sep in ["\n\n", "\n---\n", "---", "###"]:
        if sep in text:
            text = text.split(sep)[0].strip()

    # Keep at most 3 sentences and ~50 words
    sentences = re.split(r'(?<=[.!?])\s+', text)
    if sentences:
        text = ' '.join(sentences[:3])
    words = text.split()
    if len(words) > 50:
        text = ' '.join(words[:50])

    # Final cleanup: remove trailing ellipses and redundant whitespace
    text = re.sub(r"\.{2,}$", "", text).strip()

    return text


def query_gemini(prompt: str) -> str:
    """
    Send a prompt to Gemini or a local LLM and return the response text.
    """
    if _can_use_gemini_api():
        try:
            response_text = _query_gemini(prompt)
        except Exception as e:
            print(f"Error querying Gemini: {e}")
            response_text = ""
    elif LOCAL_LLM_MODEL:
        try:
            response_text = _query_local_model(prompt)
        except Exception as e:
            print(f"Error querying local LLM: {e}")
            response_text = ""
    else:
        if GEMINI_API_KEY and genai is None:
            print("Gemini API key is configured, but google.generativeai is not installed.")
        return "Sorry, I am unable to process that request right now."

    # Quick relevance check: ensure the reply mentions app-related keywords.
    # If not, return a safe fallback asking the user to rephrase.
    if response_text:
        lowered = response_text.lower()
        keywords = ["search", "chat", "profile", "login", "signup", "notifications", "message", "messages", "alumni", "request"]
        if not any(k in lowered for k in keywords):
            return "I don't have that detail — try asking how to search alumni, send a chat request, or view messages."

    return response_text or "Sorry, I am unable to process that request right now."



