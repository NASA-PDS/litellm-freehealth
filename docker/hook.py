import logging

logger = logging.getLogger(__name__)

def sanitize_messages(messages):
    cleaned = []

    for m in messages:
        content = m.get("content")

        if content is None:
            continue

        # string content
        if isinstance(content, str):
            if content.strip():
                cleaned.append(m)
            continue

        # Claude-style content blocks
        if isinstance(content, list):
            if any(
                block.get("type") == "text" and block.get("text", "").strip()
                for block in content
            ):
                cleaned.append(m)

    return cleaned


def pre_call_hook(model, messages, **kwargs):
    headers = kwargs.get("headers")
    logger.info("Pre-call hook called")
    if headers and "anthropic-beta" in headers:
        headers.pop("anthropic-beta")
    return {
        "model": model,
        "messages": sanitize_messages(messages),
        **kwargs,
    }