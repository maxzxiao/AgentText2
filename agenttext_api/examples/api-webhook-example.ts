/**
 * Example: Auto-reply bot using the REST API
 *
 * This demonstrates how to build a simple auto-reply bot that:
 * 1. Watches for incoming messages via SSE
 * 2. Processes messages with custom logic
 * 3. Sends automatic replies via the API
 *
 * Prerequisites:
 * 1. Start the API server: bun run api-server.ts
 * 2. Run this bot: bun run examples/api-webhook-example.ts
 */

const BASE_URL = 'http://localhost:3000'

interface Message {
    id: string
    text: string | null
    sender: string
    senderName: string | null
    chatId: string
    isGroupChat: boolean
    isFromMe: boolean
    date: string
}

// Bot configuration
const BOT_CONFIG = {
    // Keywords to respond to
    keywords: {
        'hello': 'Hi there! 👋 How can I help you?',
        'help': 'Available commands:\n- status: Check bot status\n- time: Get current time\n- joke: Get a random joke',
        'status': 'Bot is running! ✅',
        'time': () => `Current time: ${new Date().toLocaleString()}`,
        'joke': () => {
            const jokes = [
                'Why did the developer quit? Because they didn\'t get arrays! 😄',
                'How many programmers does it take to change a light bulb? None, that\'s a hardware problem! 💡',
                'Why do programmers prefer dark mode? Because light attracts bugs! 🐛'
            ]
            return jokes[Math.floor(Math.random() * jokes.length)]!
        }
    },
    // Auto-reply for unrecognized messages
    defaultReply: 'Thanks for your message! Type "help" for available commands.',
    // Ignore group chats (optional)
    ignoreGroups: false
}

async function sendMessage(to: string, content: string) {
    try {
        const response = await fetch(`${BASE_URL}/send`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ to, content })
        })

        if (!response.ok) {
            const error = await response.json()
            throw new Error(`Failed to send: ${error.message}`)
        }

        return await response.json()
    } catch (error) {
        console.error('❌ Send error:', error)
        throw error
    }
}

async function processMessage(message: Message) {
    // Ignore messages from yourself
    if (message.isFromMe) {
        return
    }

    // Ignore group chats if configured
    if (BOT_CONFIG.ignoreGroups && message.isGroupChat) {
        console.log(`⏭️  Skipping group message from ${message.sender}`)
        return
    }

    const text = message.text?.toLowerCase() || ''
    console.log(`\n📨 Processing message from ${message.senderName || message.sender}`)
    console.log(`   Text: ${message.text}`)

    // Check for keyword matches
    let reply: string | null = null

    for (const [keyword, response] of Object.entries(BOT_CONFIG.keywords)) {
        if (text.includes(keyword.toLowerCase())) {
            reply = typeof response === 'function' ? response() : response
            break
        }
    }

    // Use default reply if no keyword match
    if (!reply) {
        reply = BOT_CONFIG.defaultReply
    }

    // Send reply
    try {
        console.log(`   Replying: ${reply}`)
        await sendMessage(message.chatId, reply)
        console.log('   ✅ Reply sent')
    } catch (error) {
        console.error('   ❌ Failed to send reply:', error)
    }
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
            console.log('✅ Watcher started')
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

        console.log('✅ Auto-reply bot is now running!')
        console.log('📬 Waiting for messages...\n')
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
                        const parsed = JSON.parse(data)

                        if (parsed.event === 'message' && parsed.message) {
                            // Process the message and send auto-reply
                            await processMessage(parsed.message)
                            console.log('─'.repeat(60))
                        } else if (parsed.event === 'error') {
                            console.error(`\n❌ Error: ${parsed.error}`)
                        }
                    } catch (parseError) {
                        // Ignore parse errors
                    }
                } else if (line.startsWith(':heartbeat')) {
                    // Keep-alive heartbeat
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
    console.log('🤖 iMessage Auto-Reply Bot\n')

    console.log('Configuration:')
    console.log(`  - Keywords: ${Object.keys(BOT_CONFIG.keywords).join(', ')}`)
    console.log(`  - Ignore groups: ${BOT_CONFIG.ignoreGroups}`)
    console.log('')

    try {
        // Start the watcher
        await startWatcher()
        console.log('')

        // Start streaming and processing messages
        await streamMessages()

    } catch (error) {
        console.error('❌ Error:', error)
        process.exit(1)
    }
}

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n\n🛑 Shutting down bot...')

    // Stop watcher
    try {
        await fetch(`${BASE_URL}/watcher/stop`, { method: 'POST' })
        console.log('✅ Watcher stopped')
    } catch (error) {
        console.error('❌ Failed to stop watcher:', error)
    }

    process.exit(0)
})

// Run bot
main().catch(console.error)
