# REST API Quick Start Guide

Get started with the iMessage REST API in 5 minutes.

## 1. Start the Server

```bash
# Using npm
npm run api

# Using Bun (recommended)
bun run api

# Direct execution
bun run api-server.ts
```

The server will start on `http://localhost:3000`.

## 2. Verify Server is Running

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-01-13T10:30:00.000Z"
}
```

## 3. Send Your First Message

```bash
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":"Hello from the API!"}'
```

Replace `+1234567890` with your actual phone number or email.

## 4. Get Unread Messages

```bash
curl http://localhost:3000/messages/unread
```

## 5. List Your Chats

```bash
curl http://localhost:3000/chats?limit=10
```

## Common Use Cases

### Send with Images

```bash
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+1234567890",
    "content": {
      "text": "Check this out!",
      "images": ["/Users/you/photo.jpg"]
    }
  }'
```

### Send Files

```bash
curl -X POST http://localhost:3000/send/file \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+1234567890",
    "filePath": "/path/to/document.pdf",
    "text": "Here is the document"
  }'
```

### Search Messages

```bash
curl "http://localhost:3000/messages?search=meeting&limit=10"
```

### Get Messages from Specific Sender

```bash
curl "http://localhost:3000/messages?sender=%2B1234567890&limit=20"
```

### List Group Chats Only

```bash
curl "http://localhost:3000/chats?type=group"
```

## Real-time Message Streaming

### 1. Start the Watcher

```bash
curl -X POST http://localhost:3000/watcher/start
```

### 2. Connect to Stream

In a new terminal:

```bash
curl -N http://localhost:3000/watcher/stream
```

This will keep the connection open and stream messages as they arrive.

### 3. Stop the Watcher

```bash
curl -X POST http://localhost:3000/watcher/stop
```

## Using from Code

### JavaScript/TypeScript

```typescript
// Send a message
const response = await fetch('http://localhost:3000/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: '+1234567890',
    content: 'Hello!'
  })
})
const result = await response.json()
console.log(result)
```

### Python

```python
import requests

# Send a message
response = requests.post(
    'http://localhost:3000/send',
    json={'to': '+1234567890', 'content': 'Hello from Python!'}
)
print(response.json())
```

### Using EventSource (Browser)

```javascript
const eventSource = new EventSource('http://localhost:3000/watcher/stream')

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data)
  if (data.event === 'message') {
    console.log('New message:', data.message)
  }
}
```

## Example Scripts

Run the included example scripts:

```bash
# TypeScript examples
npm run api:example    # Complete API client demo
npm run api:sse        # Real-time streaming demo
npm run api:bot        # Auto-reply bot demo

# Python example
python examples/api-client-example.py
```

## Environment Variables

- `PORT` - Change the server port (default: 3000)

```bash
PORT=8080 npm run api
```

## Troubleshooting

### Server won't start
- Make sure port 3000 is not already in use
- Check that you have Full Disk Access permissions granted

### Can't send messages
- Verify the recipient format (`+1234567890` or `user@example.com`)
- Check that Messages app is installed and configured

### File paths not working
- Use absolute paths for files: `/Users/you/file.pdf`
- Ensure files exist before sending

## Next Steps

- Read the [Full API Documentation](./API-README.md)
- Check out the [TypeScript Client Example](./examples/api-client-example.ts)
- Build an [Auto-reply Bot](./examples/api-webhook-example.ts)
- Explore [Server-Sent Events](./examples/api-sse-example.ts)

## Support

- Main Documentation: [README.md](./README.md)
- API Reference: [API-README.md](./API-README.md)
- Issues: https://github.com/photon-hq/imessage-kit/issues
