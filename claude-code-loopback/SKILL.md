---
name: claude-code-loopback
description: Use when building an MCP server with its own UI (web panel, Chrome extension, Electron app) that needs to send chat messages through Claude Code instead of calling the Anthropic API directly. Uses a poll-based TCP bridge.
---

# Claude Code Loopback

## Overview

Route an MCP server's UI chat through the Claude Code session that's running during development. A standalone bridge server accepts TCP connections from external clients and exposes MCP tools that Claude Code polls in a loop. The UI gets Claude Code's subscription for free -- no API key needed during development.

## When to Use

- MCP server has its own chat UI (side panel, web page, extension popup)
- You want the UI to use Claude Code's subscription instead of a separate API key during development
- In production, the UI calls the Anthropic API directly (this bridge is dev-only)

**Not for:** MCP servers that only expose tools (no UI), or production deployments.

## Architecture

```
Chrome extension / web panel / any UI client
    |
    |  TCP (newline-delimited JSON, port 9100)
    v
development-loopback bridge (MCP server)
    |
    |  asyncio.Queue connects TCP to MCP tools
    v
Claude Code (MCP client)
    |  calls check_messages() in a loop
    |  processes message with full tool access
    |  calls send_response() to reply
    v
Bridge routes response back to the waiting TCP client
```

### Key Properties

- **Claude Code IS the AI.** No API calls needed -- Claude Code processes messages in its own conversation context with full tool access.
- **Poll-based.** `check_messages(timeout_ms=500)` returns quickly. Claude Code calls it in a tight loop. No server-push required.
- **Localhost only.** Development tool -- no auth, no encryption, no persistence.
- **General purpose.** Not tied to any specific MCP server or UI. Any client that speaks newline-delimited JSON over TCP can use it.

## Setup

### 1. Install the bridge

```bash
cd development_loopback
pip install -e .
```

### 2. Add to Claude Code's MCP config

```json
{
  "mcpServers": {
    "development-loopback": {
      "command": "development-loopback",
      "type": "stdio"
    }
  }
}
```

### 3. Tell Claude Code to poll

Use a system prompt or skill that instructs Claude Code to monitor the bridge:

> You are monitoring the development loopback bridge. Call `check_messages()` repeatedly. When a message arrives, process it using your available tools and knowledge, then call `send_response()` with your answer. Resume polling.

## Wire Protocol

Newline-delimited JSON over TCP (port 9100).

```json
// Client -> Bridge (chat request)
{"type": "chat", "conversation_id": "conv_123", "text": "How do I add a fillet?", "context": {"documentId": "abc"}}

// Bridge -> Client (response)
{"type": "response", "conversation_id": "conv_123", "text": "To add a fillet, select the edge..."}
```

The `context` field is opaque -- passed through to Claude Code for whatever use.

## Client Integration Pattern

Any MCP server UI that wants to use the loopback in dev mode:

```python
import asyncio
import json
import uuid


async def dev_chat(text: str, context: dict | None = None) -> str:
    """Send a chat message through the development bridge."""
    reader, writer = await asyncio.open_connection("127.0.0.1", 9100)

    msg = {
        "type": "chat",
        "conversation_id": str(uuid.uuid4()),
        "text": text,
        "context": context or {},
    }
    writer.write(json.dumps(msg).encode() + b"\n")
    await writer.drain()

    response_line = await reader.readline()
    response = json.loads(response_line.decode().strip())

    writer.close()
    await writer.wait_closed()
    return response["text"]
```

### Chat Router Pattern

The UI's chat handler checks if the bridge is available and picks the right backend:

```python
async def chat(text, context):
    if await _bridge_available():
        return await dev_chat(text, context)    # through Claude Code
    else:
        return await api_chat(text, context)    # direct Anthropic API


async def _bridge_available() -> bool:
    try:
        reader, writer = await asyncio.wait_for(
            asyncio.open_connection("127.0.0.1", 9100),
            timeout=0.5,
        )
        writer.close()
        await writer.wait_closed()
        return True
    except (OSError, asyncio.TimeoutError):
        return False
```

## MCP Tools

| Tool             | Description                                                                         |
| ---------------- | ----------------------------------------------------------------------------------- |
| `check_messages` | Poll for pending messages (500ms default timeout). Returns message or no\_messages. |
| `send_response`  | Send a response back to the client by conversation\_id.                             |

## What It Doesn't Do

- **No Anthropic API key** -- Claude Code is the AI
- **No auth/encryption** -- localhost only, development use
- **No message persistence** -- in-memory queues, ephemeral
- **No tool forwarding** -- Claude Code uses its own tools directly
- **No streaming** -- responses are delivered as complete text

## Why Not Other Approaches?

| Approach               | Problem                                                                      |
| ---------------------- | ---------------------------------------------------------------------------- |
| MCP sampling           | Claude Code doesn't implement `create_message` -- calls hang indefinitely    |
| `claude -p` subprocess | Nested session detection blocks it when running inside Claude Code's process |
| Direct Anthropic API   | Works, but costs money. During dev you want your existing subscription.      |
| **Poll-based bridge**  | Works. Claude Code polls via tools. No API key needed.                       |

## Provenance

Originally prototyped in `strongai/cad/onshape` (Onshape MCP server + Chrome extension). Extracted as a general-purpose standalone bridge in `claude/development_loopback`.
