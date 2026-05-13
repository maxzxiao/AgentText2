# iMessage REST API Documentation

A complete REST API wrapper for the [@photon-ai/imessage-kit](https://github.com/photon-hq/imessage-kit) TypeScript SDK.

## Quick Start

### 1. Start the API Server

```bash
# Using Bun (recommended)
bun run api-server.ts

# Using Node.js with tsx
npx tsx api-server.ts

# Using ts-node
npx ts-node api-server.ts
```

The server will start on `http://localhost:3000` (or the port specified in the `PORT` environment variable).

### 2. Test the API

```bash
# Health check
curl http://localhost:3000/health

# Get API info
curl http://localhost:3000/info
```

## API Endpoints

### Health & Info

#### `GET /health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-01-13T10:30:00.000Z"
}
```

#### `GET /info`
Get API information and available endpoints.

**Response:**
```json
{
  "name": "@photon-ai/imessage-kit REST API",
  "version": "1.0.0",
  "endpoints": { ... }
}
```

---

### Messages

#### `GET /messages`
Query messages with optional filters.

**Query Parameters:**
- `sender` (string): Filter by sender (phone/email)
- `unreadOnly` (boolean): Only unread messages
- `limit` (number): Max messages to return
- `since` (ISO date): Messages since this date
- `search` (string): Search message text
- `hasAttachments` (boolean): Only messages with attachments
- `excludeOwnMessages` (boolean): Exclude your own messages (default: true)

**Example:**
```bash
# Get all messages
curl http://localhost:3000/messages

# Get unread messages from a specific sender
curl "http://localhost:3000/messages?sender=%2B1234567890&unreadOnly=true"

# Search messages
curl "http://localhost:3000/messages?search=meeting&limit=10"

# Get messages with attachments since a date
curl "http://localhost:3000/messages?hasAttachments=true&since=2025-01-01T00:00:00Z"
```

**Response:**
```json
{
  "messages": [
    {
      "id": "123",
      "guid": "...",
      "text": "Hello!",
      "sender": "+1234567890",
      "senderName": "John Doe",
      "chatId": "iMessage;+1234567890",
      "isGroupChat": false,
      "isFromMe": false,
      "isRead": true,
      "service": "iMessage",
      "attachments": [],
      "date": "2025-01-13T10:00:00.000Z"
    }
  ],
  "total": 1,
  "unreadCount": 0
}
```

#### `GET /messages/unread`
Get unread messages grouped by sender.

**Example:**
```bash
curl http://localhost:3000/messages/unread
```

**Response:**
```json
{
  "groups": [
    {
      "sender": "+1234567890",
      "messages": [...]
    },
    {
      "sender": "user@example.com",
      "messages": [...]
    }
  ],
  "total": 5,
  "senderCount": 2
}
```

---

### Sending Messages

#### `POST /send`
Send a message to a recipient or chat.

**Request Body:**
```json
{
  "to": "+1234567890",
  "content": "Hello from API!"
}
```

Or with attachments:
```json
{
  "to": "+1234567890",
  "content": {
    "text": "Check this out",
    "images": ["/path/to/photo.jpg"],
    "files": ["/path/to/document.pdf"]
  }
}
```

**Example:**
```bash
# Send text message
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":"Hello!"}'

# Send with images
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":{"text":"Photo","images":["/Users/me/photo.jpg"]}}'

# Send to group chat
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"chat45e2b868ce1e43da89af262922733382","content":"Hello group!"}'
```

**Response:**
```json
{
  "sentAt": "2025-01-13T10:30:00.000Z",
  "message": {
    "id": "456",
    "text": "Hello!",
    ...
  }
}
```

#### `POST /send/batch`
Send multiple messages at once.

**Request Body:**
```json
{
  "messages": [
    { "to": "+1234567890", "content": "Hello!" },
    { "to": "user@example.com", "content": { "text": "Hi", "images": ["photo.jpg"] } }
  ]
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/send/batch \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"to":"+1111111111","content":"Message 1"},{"to":"+2222222222","content":"Message 2"}]}'
```

**Response:**
```json
[
  {
    "to": "+1234567890",
    "success": true,
    "result": { "sentAt": "..." }
  },
  {
    "to": "user@example.com",
    "success": true,
    "result": { "sentAt": "..." }
  }
]
```

#### `POST /send/file`
Send a single file.

**Request Body:**
```json
{
  "to": "+1234567890",
  "filePath": "/path/to/document.pdf",
  "text": "Here's the file"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/send/file \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","filePath":"/Users/me/document.pdf","text":"Document attached"}'
```

#### `POST /send/files`
Send multiple files.

**Request Body:**
```json
{
  "to": "+1234567890",
  "filePaths": ["/file1.pdf", "/file2.csv"],
  "text": "Multiple files"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/send/files \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","filePaths":["/file1.pdf","/file2.csv"]}'
```

---

### Chats

#### `GET /chats`
List chats with optional filters.

**Query Parameters:**
- `type` (string): Filter by type ('group' or 'direct')
- `hasUnread` (boolean): Only chats with unread messages
- `sortBy` (string): Sort order ('recent' or 'name')
- `search` (string): Search chat names
- `limit` (number): Max chats to return

**Example:**
```bash
# Get all chats
curl http://localhost:3000/chats

# Get group chats only
curl "http://localhost:3000/chats?type=group"

# Get chats with unread messages
curl "http://localhost:3000/chats?hasUnread=true"

# Search chats
curl "http://localhost:3000/chats?search=John"

# Recent 10 chats
curl "http://localhost:3000/chats?limit=10&sortBy=recent"
```

**Response:**
```json
[
  {
    "chatId": "chat45e2b868ce1e43da89af262922733382",
    "guid": "chat45e2b868ce1e43da89af262922733382",
    "displayName": "Project Team",
    "lastMessageAt": "2025-01-13T10:00:00.000Z",
    "isGroup": true,
    "unreadCount": 3
  },
  {
    "chatId": "iMessage;+1234567890",
    "guid": "...",
    "displayName": "John Doe",
    "lastMessageAt": "2025-01-13T09:00:00.000Z",
    "isGroup": false,
    "unreadCount": 0
  }
]
```

---

### Message Watcher (Real-time)

#### `POST /watcher/start`
Start watching for new messages.

**Example:**
```bash
curl -X POST http://localhost:3000/watcher/start
```

**Response:**
```json
{
  "status": "Watcher started",
  "timestamp": "2025-01-13T10:30:00.000Z"
}
```

#### `POST /watcher/stop`
Stop watching for new messages.

**Example:**
```bash
curl -X POST http://localhost:3000/watcher/stop
```

**Response:**
```json
{
  "status": "Watcher stopped",
  "timestamp": "2025-01-13T10:30:00.000Z"
}
```

#### `GET /watcher/status`
Get watcher status.

**Example:**
```bash
curl http://localhost:3000/watcher/status
```

**Response:**
```json
{
  "active": true,
  "connections": 2,
  "timestamp": "2025-01-13T10:30:00.000Z"
}
```

#### `GET /watcher/stream`
Stream messages via Server-Sent Events (SSE).

This endpoint keeps the connection open and streams messages in real-time as they arrive.

**Example (JavaScript):**
```javascript
const eventSource = new EventSource('http://localhost:3000/watcher/stream')

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data)

  if (data.event === 'connected') {
    console.log('Connected to stream')
  } else if (data.event === 'message') {
    console.log('New message:', data.message)
  } else if (data.event === 'error') {
    console.error('Error:', data.error)
  }
}

eventSource.onerror = (error) => {
  console.error('SSE error:', error)
}

// Close when done
// eventSource.close()
```

**Example (curl):**
```bash
curl -N http://localhost:3000/watcher/stream
```

**SSE Message Format:**
```
data: {"event":"connected","timestamp":"2025-01-13T10:30:00.000Z"}

data: {"event":"message","message":{"id":"123","text":"Hello",...}}

data: {"event":"error","error":"Something went wrong"}
```

---

## Using with External Scripts

### Python Example

```python
import requests

BASE_URL = "http://localhost:3000"

# Send a message
response = requests.post(
    f"{BASE_URL}/send",
    json={"to": "+1234567890", "content": "Hello from Python!"}
)
print(response.json())

# Get unread messages
response = requests.get(f"{BASE_URL}/messages/unread")
unread = response.json()
print(f"{unread['total']} unread messages from {unread['senderCount']} senders")

# List chats
response = requests.get(f"{BASE_URL}/chats?type=group")
chats = response.json()
for chat in chats:
    print(f"{chat['displayName']}: {chat['unreadCount']} unread")
```

### JavaScript/Node.js Example

```javascript
// Send a message
const sendMessage = async (to, content) => {
  const response = await fetch('http://localhost:3000/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ to, content })
  })
  return response.json()
}

// Get messages
const getMessages = async (filters = {}) => {
  const params = new URLSearchParams(filters)
  const response = await fetch(`http://localhost:3000/messages?${params}`)
  return response.json()
}

// Usage
await sendMessage('+1234567890', 'Hello!')
const messages = await getMessages({ unreadOnly: true, limit: 10 })
```

### cURL Examples

```bash
# Send a message
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":"Hello from cURL!"}'

# Get unread messages
curl http://localhost:3000/messages/unread

# Search messages
curl "http://localhost:3000/messages?search=meeting"

# List group chats
curl "http://localhost:3000/chats?type=group"

# Start watcher
curl -X POST http://localhost:3000/watcher/start

# Stream messages (keeps connection open)
curl -N http://localhost:3000/watcher/stream
```

---

## Environment Variables

- `PORT` - Server port (default: 3000)

---

## Error Responses

All errors follow this format:

```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (invalid parameters)
- `500` - Internal Server Error

---

## Features

✅ **Complete SDK Coverage** - All iMessage SDK methods exposed via REST
✅ **Real-time Streaming** - SSE support for live message updates
✅ **Batch Operations** - Send multiple messages efficiently
✅ **Type Safety** - Full TypeScript type definitions included
✅ **Cross-platform** - Call from any language/platform via HTTP
✅ **Graceful Shutdown** - Proper cleanup on server stop
✅ **Error Handling** - Comprehensive error responses

---

## Security Notes

- This API runs locally and has full access to your iMessage database
- Use authentication/authorization if exposing the API to a network
- Be careful with file paths - ensure proper validation in production
- The API does not include rate limiting by default

---

## Advanced Usage

### Custom Port

```bash
PORT=8080 bun run api-server.ts
```

### Running in Production

For production use, consider:
1. Adding authentication (JWT, API keys, etc.)
2. Implementing rate limiting
3. Using a process manager (PM2, systemd)
4. Setting up HTTPS with a reverse proxy (nginx, Caddy)
5. Adding request validation middleware
6. Implementing proper logging

### Integration with CI/CD

You can call the API from CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Send notification
  run: |
    curl -X POST http://your-server:3000/send \
      -H "Content-Type: application/json" \
      -d '{"to":"${{ secrets.PHONE }}","content":"Build completed!"}'
```

---

## TypeScript Types

See [api-types.ts](./api-types.ts) for complete type definitions that can be used in client applications.

---

## Support

For issues or questions:
- SDK Documentation: https://github.com/photon-hq/imessage-kit
- Open an issue: https://github.com/photon-hq/imessage-kit/issues
