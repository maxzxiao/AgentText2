# iMessage REST API Cheat Sheet

Quick reference for the most common API operations.

## Start Server

```bash
npm run api        # Start on port 3000
PORT=8080 npm run api  # Custom port
```

## Quick Commands

### Send Messages
```bash
# Text
curl -X POST http://localhost:3000/send -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":"Hello!"}'

# With image
curl -X POST http://localhost:3000/send -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":{"text":"Photo","images":["/path/to/photo.jpg"]}}'

# File only
curl -X POST http://localhost:3000/send/file -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","filePath":"/path/to/file.pdf"}'

# Batch
curl -X POST http://localhost:3000/send/batch -H "Content-Type: application/json" \
  -d '{"messages":[{"to":"+1111111111","content":"Hi"},{"to":"+2222222222","content":"Hello"}]}'
```

### Query Messages
```bash
# All messages
curl http://localhost:3000/messages

# Unread only
curl "http://localhost:3000/messages?unreadOnly=true"

# From specific sender
curl "http://localhost:3000/messages?sender=%2B1234567890"

# Search
curl "http://localhost:3000/messages?search=meeting"

# Unread grouped
curl http://localhost:3000/messages/unread
```

### List Chats
```bash
# All chats
curl http://localhost:3000/chats

# Groups only
curl "http://localhost:3000/chats?type=group"

# With unread
curl "http://localhost:3000/chats?hasUnread=true"

# Search
curl "http://localhost:3000/chats?search=John"
```

### Watcher
```bash
# Start
curl -X POST http://localhost:3000/watcher/start

# Stop
curl -X POST http://localhost:3000/watcher/stop

# Status
curl http://localhost:3000/watcher/status

# Stream (keeps connection open)
curl -N http://localhost:3000/watcher/stream
```

## JavaScript/TypeScript

```javascript
const BASE_URL = 'http://localhost:3000'

// Send message
await fetch(`${BASE_URL}/send`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ to: '+1234567890', content: 'Hello!' })
})

// Get messages
const res = await fetch(`${BASE_URL}/messages?limit=10`)
const data = await res.json()

// SSE stream
const eventSource = new EventSource(`${BASE_URL}/watcher/stream`)
eventSource.onmessage = (e) => {
  const data = JSON.parse(e.data)
  if (data.event === 'message') console.log(data.message)
}
```

## Python

```python
import requests

BASE = "http://localhost:3000"

# Send
requests.post(f"{BASE}/send", json={"to": "+1234567890", "content": "Hi"})

# Get messages
r = requests.get(f"{BASE}/messages", params={"limit": 10})
print(r.json())

# Unread
unread = requests.get(f"{BASE}/messages/unread").json()
print(f"{unread['total']} unread")
```

## Common Filters

### Messages
- `sender` - Filter by phone/email
- `unreadOnly` - true/false
- `limit` - Number of messages
- `since` - ISO date string
- `search` - Search text
- `hasAttachments` - true/false
- `excludeOwnMessages` - true/false (default: true)

### Chats
- `type` - 'group' or 'direct'
- `hasUnread` - true/false
- `sortBy` - 'recent' or 'name'
- `search` - Search chat names
- `limit` - Number of chats

## Response Formats

### Send Result
```json
{
  "sentAt": "2025-01-13T10:30:00.000Z",
  "message": { /* Message object if watcher is running */ }
}
```

### Messages
```json
{
  "messages": [
    {
      "id": "123",
      "text": "Hello",
      "sender": "+1234567890",
      "chatId": "iMessage;+1234567890",
      "isGroupChat": false,
      "date": "2025-01-13T10:00:00.000Z"
    }
  ],
  "total": 1,
  "unreadCount": 0
}
```

### Chats
```json
[
  {
    "chatId": "chat123...",
    "displayName": "Project Team",
    "isGroup": true,
    "unreadCount": 3,
    "lastMessageAt": "2025-01-13T10:00:00.000Z"
  }
]
```

### SSE Events
```
data: {"event":"connected","timestamp":"..."}
data: {"event":"message","message":{...}}
data: {"event":"error","error":"..."}
```

## Status Codes

- `200` - Success
- `400` - Bad Request (invalid parameters)
- `500` - Internal Server Error

## Error Format
```json
{
  "error": "Error type",
  "message": "Detailed message"
}
```

## Examples

```bash
# Run TypeScript examples
npm run api:example   # Complete demo
npm run api:sse       # Real-time streaming
npm run api:bot       # Auto-reply bot

# Run Python example
python examples/api-client-example.py
```

## Documentation

- [Quick Start](./API-QUICKSTART.md) - Get started in 5 minutes
- [Full API Docs](./API-README.md) - Complete documentation
- [Summary](./REST-API-SUMMARY.md) - Implementation overview
- [Main README](./README.md) - SDK documentation

## Tips

💡 URL encode phone numbers: `+1234567890` → `%2B1234567890`
💡 Use absolute paths for files: `/Users/you/file.pdf`
💡 Start watcher before using `/watcher/stream`
💡 Keep SSE connections alive with `-N` flag in cURL
💡 Set `PORT` env var to change server port

---

Quick links:
- GitHub: https://github.com/photon-hq/imessage-kit
- Issues: https://github.com/photon-hq/imessage-kit/issues
