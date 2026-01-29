---
name: aistudio
description: Unofficial Python client for Google AI Studio. Browser-based authentication, generate content, list models. Activates on "AI Studio", "aistudio", "Gemini 生成", "前端生成"
---

# AI Studio Automation

Unofficial Python client for Google AI Studio. Uses browser-based authentication similar to notebooklm-py.

> ⚠️ **Unofficial Library** - Uses undocumented Google APIs that can change without notice.

## Installation

```bash
# Clone and install
cd ~/LM/aistudio-py
pip install -e ".[browser]"
playwright install chromium
```

## Prerequisites

**IMPORTANT:** Before using any command, you MUST authenticate:

```bash
aistudio login    # Opens browser for Google login
aistudio status   # Verify authentication works
```

## When This Skill Activates

**Explicit:** User says "AI Studio", "aistudio", "use AI Studio"

**Intent detection:** Recognize requests like:
- "用 AI Studio 生成..."
- "帮我用 Gemini 写..."
- "Generate content with AI Studio"
- "前端代码生成"

## Quick Reference

| Task | Command |
|------|---------|
| Authenticate | `aistudio login` |
| Check status | `aistudio status` |
| Generate content | `aistudio ask "prompt"` |
| List models | `aistudio models` |
| Count tokens | `aistudio tokens "text"` |

## CLI Options

```bash
# Generate with specific model
aistudio ask "Write a React component" -m models/gemini-2.0-flash

# Adjust temperature
aistudio ask "Creative writing" -t 1.5

# Set max tokens
aistudio ask "Long response" --max-tokens 16384
```

## Python API

```python
import asyncio
from aistudio import AIStudioClient, AIStudioAuth

async def main():
    auth = AIStudioAuth.from_storage()
    async with AIStudioClient(auth) as client:
        # Generate content
        result = await client.generate_content(
            prompt="Write a React component for a todo list",
            model="models/gemini-2.0-flash",
            temperature=1.0,
            max_tokens=8192,
        )
        print(result)
        
        # Count tokens
        count = await client.count_tokens("Hello world")
        print(f"Tokens: {count}")

asyncio.run(main())
```

## Common Workflows

### Generate Frontend Code

```bash
# Generate React component
aistudio ask "Create a modern React component for a user profile card with Tailwind CSS"

# Generate HTML/CSS
aistudio ask "Create a responsive landing page with hero section"
```

### Code Review

```bash
# Review code
aistudio ask "Review this code and suggest improvements: $(cat myfile.py)"
```

### Documentation

```bash
# Generate docs
aistudio ask "Write documentation for this function: $(cat function.py)"
```

## Authentication

Credentials are stored in `~/.aistudio/`:
- `storage_state.json` - Browser cookies
- `credentials.json` - API key and tokens

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `AISTUDIO_HOME` | Custom config directory (default: `~/.aistudio`) |

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| "Credentials not found" | Not logged in | Run `aistudio login` |
| "Missing required cookies" | Session expired | Re-run `aistudio login` |
| HTTP 401/403 | Auth expired | Re-run `aistudio login` |
| HTTP 429 | Rate limited | Wait and retry |

## Comparison with Official API

| Feature | AI Studio (this tool) | Official Gemini API |
|---------|----------------------|---------------------|
| Auth | Browser cookies | API Key |
| Stability | ⚠️ Unofficial | ✅ Official |
| Free tier | Uses your account quota | Separate quota |
| Setup | Browser login | Get API key |

## Troubleshooting

```bash
aistudio --help     # Show all commands
aistudio status     # Check auth status
aistudio login      # Re-authenticate
```

## Limitations

- **Session expiry**: Cookies may expire, requiring re-login
- **Rate limits**: Google may throttle heavy usage
- **API changes**: Google can change internal APIs without notice

## Source Code

Located at: `~/LM/aistudio-py/`

```
src/aistudio/
├── __init__.py    # Package exports
├── auth.py        # Authentication handling
├── client.py      # API client
└── cli.py         # CLI commands
```
