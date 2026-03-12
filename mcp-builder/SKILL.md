---
name: mcp-builder
description: Use when building MCP servers with Python FastMCP SDK, adding tools/resources/prompts to an MCP server, or scaffolding a new MCP project
---

# Building MCP Servers with FastMCP

## Overview

FastMCP (`mcp.server.fastmcp.FastMCP`) is the high-level Python SDK for building MCP servers. It uses decorators and type hints to auto-generate JSON schemas. This skill covers server setup, tool/resource/prompt registration, transport configuration, and project structure.

## When to Use

- Scaffolding a new MCP server project
- Adding tools, resources, or prompts to an existing FastMCP server
- Configuring transport (stdio, SSE, streamable-http)
- Setting up lifespan hooks for shared state (DB connections, HTTP clients)

## Quick Reference

| Feature | API |
|---------|-----|
| Server | `FastMCP(name, lifespan=...)` |
| Tool | `@mcp.tool(name=, description=)` |
| Resource | `@mcp.resource(uri, name=, mime_type=)` |
| Prompt | `@mcp.prompt(name=, description=)` |
| Context | Type-hint any param as `Context` |
| Run | `mcp.run(transport="stdio")` |

## Project Structure

```
my-mcp/
  pyproject.toml          # Package config, entry point
  .env                    # ONSHAPE_ACCESS_KEY, etc.
  src/
    my_mcp/
      __init__.py
      server.py           # FastMCP instance + tool registrations
      main.py             # CLI entry point (start/stop/status/run)
      api/                # Domain-specific API clients
        client.py         # HTTP client (httpx async)
        ...
      tools/              # Tool modules grouped by domain
        documents.py      # @mcp.tool() functions
        ...
```

**Key rule:** Keep `server.py` as the single FastMCP instance owner. Tool modules import it and register via decorators. The `main.py` handles CLI and calls `server.run()`.

## Core Pattern

### 1. Server Instance with Lifespan

```python
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator
from mcp.server.fastmcp import FastMCP, Context

@asynccontextmanager
async def app_lifespan(app: FastMCP) -> AsyncIterator[dict]:
    """Initialize shared resources available via ctx.request_context.lifespan_context."""
    async with SomeClient() as client:
        yield {"client": client}

mcp = FastMCP(
    name="my-server",
    lifespan=app_lifespan,
)
```

The dict yielded by lifespan is accessible in tools via `ctx.request_context.lifespan_context["client"]`.

### 2. Tool Registration

```python
@mcp.tool(name="get_document", description="Get document details")
async def get_document(
    document_id: str,
    include_metadata: bool = False,
    ctx: Context = None,  # Optional context injection
) -> str:
    """Docstring becomes description if not set in decorator."""
    client = ctx.request_context.lifespan_context["client"]
    result = await client.get(f"/api/docs/{document_id}")
    return str(result)
```

**Type hint rules for auto-schema:**
- `str`, `int`, `float`, `bool` -> JSON primitives
- `str | None` -> optional string (use for Optional params)
- `list[float]` -> array of numbers
- `Literal["A", "B", "C"]` -> enum with allowed values
- `Context` -> injected, NOT included in schema
- Default values -> parameter defaults in schema

**Return types:**
- `str` -> returned as text content
- `list[str]` -> multiple text content items
- Return type is NOT part of the tool schema, only input params are

### 3. Resource Registration

```python
@mcp.resource("config://app/settings", mime_type="application/json")
def get_settings() -> str:
    return json.dumps(load_settings())

@mcp.resource("docs://{doc_id}/content")  # Template resource
async def get_doc_content(doc_id: str) -> str:
    return await fetch_doc(doc_id)
```

### 4. Prompt Registration

```python
@mcp.prompt(name="analyze", description="Analyze a document")
def analyze_prompt(doc_name: str) -> str:
    return f"Please analyze the document: {doc_name}"
```

### 5. Running the Server

```python
if __name__ == "__main__":
    mcp.run(transport="stdio")  # Default for Claude Code / MCP clients
```

Transport options: `"stdio"` (default), `"sse"`, `"streamable-http"`.

## Tool Design Patterns

### Grouping Tools by Domain

Split tools across modules. Each module imports the shared `mcp` instance:

```python
# tools/documents.py
from ..server import mcp

@mcp.tool(name="list_documents", description="List documents")
async def list_documents(limit: int = 20) -> str:
    ...
```

**Import all tool modules in server.py** so decorators execute:

```python
# server.py
mcp = FastMCP(name="my-server", lifespan=app_lifespan)

# Register all tool modules (decorators run on import)
from .tools import documents, assemblies, exports  # noqa: F401, E402
```

### Enum Parameters

Use `Literal` for constrained string choices:

```python
@mcp.tool(name="export_part", description="Export to format")
async def export_part(
    document_id: str,
    format: Literal["STL", "STEP", "GLTF", "OBJ"] = "STL",
) -> str:
    ...
```

### Array Parameters

Use `list[type]` for arrays:

```python
@mcp.tool(name="transform_instance", description="Apply 4x4 transform")
async def transform_instance(
    instance_id: str,
    matrix: list[float],  # 16-element row-major 4x4
) -> str:
    ...
```

### Large Tool Return Values

Always return `str`. Format multi-part results as readable text:

```python
@mcp.tool(name="check_interference", description="Check part overlaps")
async def check_interference(document_id: str, ...) -> str:
    result = await run_check(...)
    lines = [f"Found {len(result.overlaps)} overlap(s):"]
    for ov in result.overlaps:
        lines.append(f"  {ov.part_a} <-> {ov.part_b}: {ov.volume:.3f} cu in")
    return "\n".join(lines)
```

### Error Handling

Let exceptions propagate naturally — FastMCP converts them to MCP error responses. For domain errors, return descriptive strings:

```python
@mcp.tool(name="get_feature", description="Get feature by ID")
async def get_feature(document_id: str, feature_id: str, ctx: Context) -> str:
    try:
        result = await client.get(f"/api/features/{feature_id}")
        return json.dumps(result, indent=2)
    except httpx.HTTPStatusError as e:
        return f"Error {e.response.status_code}: {e.response.text}"
```

## Lifespan for Shared State

The lifespan context manager is the correct way to manage shared resources (HTTP clients, DB connections). The yielded value is available in every tool via Context:

```python
@asynccontextmanager
async def app_lifespan(app: FastMCP) -> AsyncIterator[dict]:
    client = httpx.AsyncClient(base_url="https://api.example.com")
    try:
        yield {"http": client}
    finally:
        await client.aclose()

mcp = FastMCP(name="my-server", lifespan=app_lifespan)

@mcp.tool()
async def my_tool(query: str, ctx: Context) -> str:
    http = ctx.request_context.lifespan_context["http"]
    resp = await http.get(f"/search?q={query}")
    return resp.text
```

## CLI Entry Point Pattern

For daemon-mode MCP servers:

```python
# main.py
import argparse, os, signal, sys
from .server import mcp

PID_FILE = os.path.expanduser("~/.cache/my-mcp/server.pid")

def cmd_run():
    """Run in foreground (for Claude Code stdio)."""
    mcp.run(transport="stdio")

def cmd_start():
    """Start as background daemon (SSE/HTTP)."""
    # Fork, write PID, run mcp.run(transport="sse")

def cmd_stop():
    """Stop daemon by PID."""
    # Read PID, send SIGTERM

def cmd_status():
    """Check if daemon running."""
    # Read PID, check process exists

def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command")
    sub.add_parser("run")
    sub.add_parser("start")
    sub.add_parser("stop")
    sub.add_parser("status")
    args = parser.parse_args()
    {"run": cmd_run, "start": cmd_start, "stop": cmd_stop, "status": cmd_status}[args.command]()
```

## pyproject.toml

```toml
[project]
name = "my-mcp"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
    "mcp>=1.0",
    "httpx",
    "python-dotenv",
]

[project.scripts]
my-mcp = "my_mcp.main:main"
```

## .mcp.json Configuration

For Claude Code integration:

```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "/path/to/venv/bin/my-mcp",
      "args": ["run"]
    }
  }
}
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting to import tool modules in server.py | Decorators only run on import. Add `from .tools import X` |
| Using `Optional[str]` instead of `str \| None` | Both work, but `str \| None` is cleaner for 3.10+ |
| Returning dict from tool | Return `str` (use `json.dumps` if needed) |
| Creating httpx client per request | Use lifespan to share a single client |
| Not closing httpx client on shutdown | Use lifespan's finally/cleanup block |
| Context as required param | Give it a default: `ctx: Context = None` |
| Putting all tools in one file | Split by domain into `tools/` modules |
