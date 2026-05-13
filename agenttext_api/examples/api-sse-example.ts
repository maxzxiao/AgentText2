/**
 * Example: Real-time message streaming with Server-Sent Events (SSE)
 *
 * This demonstrates how to receive real-time message updates from the API.
 *
 * Prerequisites:
 * 1. Start the API server: bun run api-server.ts
 * 2. Start the watcher: curl -X POST http://localhost:3000/watcher/start
 * 3. Run this example: bun run examples/api-sse-example.ts
 *
 * Note: This example works in Node.js/Bun. For browser, use EventSource directly.
 */

const BASE_URL = 'http://localhost:3000'

interface SSEMessage {
    event: 'connected' | 'message' | 'error'
    message?: {
        id: string
        text: string | null
        sender: string
        senderName: string | null
        chatId: string
        isGroupChat: boolean
        date: string
    }
    error?: string
    timestamp?: string
}

async function startWatcher() {
    console.log('🔄 Starting watcher...')
    try {
        const response = await fetch(`${BASE_URL}/watcher/start`, {
            method: 'POST'
        })
        if (!response.ok) {
            const error = await response.json()
            if (error.error !== 'Watcher already running') {
                throw new Error(`Failed to start watcher: ${error.message}`)
            }
            console.log('⚠️  Watcher already running')
        } else {
            const result = await response.json()
            console.log('✅ Watcher started:', result.status)
        }
    } catch (error) {
        console.error('❌ Failed to start watcher:', error)
        throw error
    }
}

async function streamMessages() {
    console.log('📡 Connecting to message stream...\n')

    try {
        const response = await fetch(`${BASE_URL}/watcher/stream`)

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }

        const reader = response.body?.getReader()
        const decoder = new TextDecoder()

        if (!reader) {
            throw new Error('No response body')
        }

        console.log('✅ Connected! Listening for messages...\n')
        console.log('Press Ctrl+C to stop\n')
        console.log('─'.repeat(60))

        while (true) {
            const { done, value } = await reader.read()

            if (done) {
                console.log('\n📪 Stream ended')
                break
            }

            const chunk = decoder.decode(value, { stream: true })
            const lines = chunk.split('\n')

            for (const line of lines) {
                if (line.startsWith('data: ')) {
                    const data = line.substring(6)

                    try {
                        const parsed: SSEMessage = JSON.parse(data)

                        if (parsed.event === 'connected') {
                            console.log(`🟢 Connected at ${parsed.timestamp}`)
                        } else if (parsed.event === 'message' && parsed.message) {
                            const msg = parsed.message
                            const chatType = msg.isGroupChat ? '👥 Group' : '💬 DM'
                            const senderName = msg.senderName || msg.sender
                            const messageText = msg.text || '[attachment]'

                            console.log('\n📨 New Message')
                            console.log(`   ${chatType} from: ${senderName}`)
                            console.log(`   Text: ${messageText}`)
                            console.log(`   Chat ID: ${msg.chatId}`)
                            console.log(`   Time: ${new Date(msg.date).toLocaleString()}`)
                            console.log('─'.repeat(60))
                        } else if (parsed.event === 'error') {
                            console.error(`\n❌ Error: ${parsed.error}`)
                        }
                    } catch (parseError) {
                        // Ignore parse errors (heartbeats, etc.)
                    }
                } else if (line.startsWith(':heartbeat')) {
                    // Heartbeat to keep connection alive
                    process.stdout.write('.')
                }
            }
        }
    } catch (error) {
        console.error('\n❌ Stream error:', error)
        throw error
    }
}

async function main() {
    console.log('🚀 iMessage Real-time Message Streaming Example\n')

    try {
        // Start the watcher
        await startWatcher()

        console.log('')

        // Start streaming
        await streamMessages()

    } catch (error) {
        console.error('❌ Error:', error)
        process.exit(1)
    }
}

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n\n🛑 Shutting down...')
    process.exit(0)
})

// Run example
main().catch(console.error)
