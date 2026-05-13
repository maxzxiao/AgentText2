# REST API Implementation Summary

This document summarizes the REST API wrapper that has been added to the iMessage SDK.

## What Was Built

A complete Express.js REST API server that wraps the entire `@photon-ai/imessage-kit` TypeScript SDK, making all functionality accessible via HTTP endpoints.

## Files Created

### 1. Core API Server
- **[api-server.ts](./api-server.ts)** - Main Express server with all endpoints
  - Health check and info endpoints
  - Message querying endpoints (with filters)
  - Message sending endpoints (text, images, files, batch)
  - Chat listing endpoints
  - Real-time watcher endpoints
  - Server-Sent Events (SSE) streaming support
  - Graceful shutdown handling

### 2. Type Definitions
- **[api-types.ts](./api-types.ts)** - Complete TypeScript types for the API
  - Request/response types for all endpoints
  - SSE message types
  - Client configuration types
  - Can be imported by client applications

### 3. Documentation
- **[API-README.md](./API-README.md)** - Comprehensive API documentation
  - All endpoints with examples
  - cURL examples
  - JavaScript/TypeScript examples
  - Python examples
  - SSE streaming guide
  - Error handling
  - Security notes

- **[API-QUICKSTART.md](./API-QUICKSTART.md)** - Quick start guide
  - Get started in 5 minutes
  - Common use cases
  - Troubleshooting

### 4. Example Scripts

#### TypeScript/JavaScript Examples
- **[examples/api-client-example.ts](./examples/api-client-example.ts)**
  - Complete client demonstration
  - Shows all major endpoints
  - Run with: `npm run api:example`

- **[examples/api-sse-example.ts](./examples/api-sse-example.ts)**
  - Real-time message streaming
  - Server-Sent Events demo
  - Run with: `npm run api:sse`

- **[examples/api-webhook-example.ts](./examples/api-webhook-example.ts)**
  - Auto-reply bot implementation
  - Keyword-based responses
  - SSE message processing
  - Run with: `npm run api:bot`

#### Python Example
- **[examples/api-client-example.py](./examples/api-client-example.py)**
  - Python client class
  - Complete API coverage
  - Run with: `python examples/api-client-example.py`

## API Endpoints

### Health & Info
- `GET /health` - Health check
- `GET /info` - API information and available endpoints

### Messages
- `GET /messages` - Query messages (with filters: sender, search, unreadOnly, hasAttachments, etc.)
- `GET /messages/unread` - Get unread messages grouped by sender

### Sending
- `POST /send` - Send message (text, images, files)
- `POST /send/batch` - Send multiple messages
- `POST /send/file` - Send single file
- `POST /send/files` - Send multiple files

### Chats
- `GET /chats` - List chats (with filters: type, hasUnread, search, sortBy)

### Watcher (Real-time)
- `POST /watcher/start` - Start message watcher
- `POST /watcher/stop` - Stop message watcher
- `GET /watcher/status` - Get watcher status
- `GET /watcher/stream` - SSE stream for real-time messages

## Features

✅ **Complete SDK Coverage** - Every SDK method is exposed via REST
✅ **Real-time Streaming** - Server-Sent Events for live message updates
✅ **Batch Operations** - Send multiple messages efficiently
✅ **Type Safety** - Full TypeScript types for client apps
✅ **Cross-platform** - Call from any language (Python, cURL, etc.)
✅ **Graceful Shutdown** - Proper cleanup on server stop
✅ **Error Handling** - Comprehensive error responses
✅ **Example Scripts** - Ready-to-use examples in multiple languages

## Usage

### Start the Server

```bash
# Using npm scripts
npm run api

# Using bun
bun run api

# Direct execution
bun run api-server.ts
```

Server runs on `http://localhost:3000` (configurable via `PORT` env var).

### Send a Message

```bash
curl -X POST http://localhost:3000/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+1234567890","content":"Hello!"}'
```

### Stream Messages in Real-time

```bash
# Start watcher
curl -X POST http://localhost:3000/watcher/start

# Connect to stream
curl -N http://localhost:3000/watcher/stream
```

### Use from Python

```python
import requests

response = requests.post(
    'http://localhost:3000/send',
    json={'to': '+1234567890', 'content': 'Hello from Python!'}
)
print(response.json())
```

## npm Scripts Added

- `npm run api` - Start the API server
- `npm run api:example` - Run TypeScript client example
- `npm run api:sse` - Run SSE streaming example
- `npm run api:bot` - Run auto-reply bot example

## Dependencies Added

- `express` - Web server framework
- `cors` - CORS middleware
- `body-parser` - Request body parsing
- `@types/express`, `@types/cors`, `@types/body-parser` - TypeScript types

## Use Cases

1. **External Scripts** - Call iMessage from Python, shell scripts, etc.
2. **Web Integration** - Build web apps that send/receive iMessages
3. **Automation** - Integrate with CI/CD, cron jobs, webhooks
4. **Bots** - Build chatbots with auto-reply functionality
5. **Monitoring** - Real-time message monitoring via SSE
6. **Multi-language** - Use iMessage SDK from any programming language

## Architecture

```
┌─────────────────┐
│  External App   │ (Python, cURL, JS, etc.)
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│  Express Server │ (api-server.ts)
│  Port 3000      │
└────────┬────────┘
         │ SDK Calls
         ▼
┌─────────────────┐
│  IMessageSDK    │ (TypeScript SDK)
└────────┬────────┘
         │ AppleScript
         ▼
┌─────────────────┐
│  Messages.app   │ (macOS iMessage)
└─────────────────┘
```

## Real-time Architecture

```
┌──────────────┐         ┌──────────────┐
│   Client 1   │◄────SSE─┤              │
└──────────────┘         │              │
                         │    Express   │         ┌─────────────┐
┌──────────────┐         │    Server    │◄────────┤  Watcher    │
│   Client 2   │◄────SSE─┤              │         │  (Polling)  │
└──────────────┘         │              │         └──────┬──────┘
                         └──────────────┘                │
┌──────────────┐                                         │
│   Client N   │◄────SSE─────────────────────────────────┘
└──────────────┘                                         │
                                                         ▼
                                                  ┌─────────────┐
                                                  │ chat.db     │
                                                  │ (iMessage)  │
                                                  └─────────────┘
```

## Security Considerations

⚠️ **Important**: This API has full access to your iMessage database. For production use:

1. Add authentication (JWT, API keys)
2. Implement rate limiting
3. Use HTTPS with reverse proxy
4. Validate all file paths
5. Don't expose to public networks without security
6. Consider IP whitelisting

## Next Steps

1. Read the [Quick Start Guide](./API-QUICKSTART.md)
2. Review [Full API Documentation](./API-README.md)
3. Run the example scripts
4. Build your own integration!

## Production Deployment Ideas

- **Process Manager**: Use PM2 or systemd
- **Reverse Proxy**: nginx or Caddy for HTTPS
- **Authentication**: Add JWT or API key middleware
- **Rate Limiting**: Add express-rate-limit
- **Logging**: Add structured logging (pino, winston)
- **Monitoring**: Add health checks and metrics
- **Docker**: Containerize for easier deployment

## Contributing

Feel free to extend the API with:
- Additional endpoints
- Authentication middleware
- Rate limiting
- WebSocket support (alternative to SSE)
- GraphQL endpoint
- OpenAPI/Swagger documentation

---

Built with ❤️ for the iMessage Kit community
