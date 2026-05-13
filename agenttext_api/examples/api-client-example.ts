/**
 * Example: Using the iMessage REST API with TypeScript/JavaScript
 *
 * This demonstrates how to call the REST API endpoints from an external script.
 *
 * Prerequisites:
 * 1. Start the API server: bun run api-server.ts
 * 2. Run this example: bun run examples/api-client-example.ts
 */

// API Base URL
const BASE_URL = 'http://localhost:3000'

// Helper function to make API calls
async function apiCall<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
        headers: {
            'Content-Type': 'application/json',
            ...options.headers,
        },
        ...options,
    })

    if (!response.ok) {
        const error = await response.json()
        throw new Error(`API Error: ${error.error} - ${error.message}`)
    }

    return response.json()
}

// ==================== Examples ====================

async function main() {
    console.log('🚀 iMessage REST API Client Examples\n')

    // Replace with your actual phone number or test contact
    const TEST_RECIPIENT = process.env.TEST_RECIPIENT || '+1234567890'

    try {
        // 1. Health Check
        console.log('1️⃣  Health Check')
        const health = await apiCall<{ status: string; timestamp: string }>('/health')
        console.log('   Health:', health.status)
        console.log('')

        // 2. Get API Info
        console.log('2️⃣  Get API Info')
        const info = await apiCall<any>('/info')
        console.log('   API Name:', info.name)
        console.log('   Version:', info.version)
        console.log('')

        // 3. Send a Text Message
        console.log('3️⃣  Send Text Message')
        const sendResult = await apiCall<{ sentAt: string }>('/send', {
            method: 'POST',
            body: JSON.stringify({
                to: TEST_RECIPIENT,
                content: 'Hello from the REST API! 👋'
            })
        })
        console.log('   Sent at:', sendResult.sentAt)
        console.log('')

        // 4. Get Unread Messages
        console.log('4️⃣  Get Unread Messages')
        const unread = await apiCall<{
            groups: Array<{ sender: string; messages: any[] }>
            total: number
            senderCount: number
        }>('/messages/unread')
        console.log(`   Total: ${unread.total} unread messages from ${unread.senderCount} senders`)
        for (const group of unread.groups.slice(0, 3)) {
            console.log(`   - ${group.sender}: ${group.messages.length} messages`)
        }
        console.log('')

        // 5. Query Messages
        console.log('5️⃣  Query Recent Messages')
        const messages = await apiCall<{
            messages: any[]
            total: number
            unreadCount: number
        }>('/messages?limit=5')
        console.log(`   Found ${messages.total} messages (showing ${messages.messages.length})`)
        for (const msg of messages.messages) {
            console.log(`   - ${msg.sender}: ${msg.text?.substring(0, 50) || '[attachment]'}`)
        }
        console.log('')

        // 6. List Chats
        console.log('6️⃣  List Chats')
        const chats = await apiCall<Array<{
            chatId: string
            displayName: string
            isGroup: boolean
            unreadCount: number
        }>>('/chats?limit=5')
        console.log(`   Found ${chats.length} chats:`)
        for (const chat of chats) {
            const type = chat.isGroup ? '👥 Group' : '💬 DM'
            const unread = chat.unreadCount > 0 ? ` (${chat.unreadCount} unread)` : ''
            console.log(`   ${type}: ${chat.displayName}${unread}`)
        }
        console.log('')

        // 7. Search Messages
        console.log('7️⃣  Search Messages')
        const searchTerm = 'hello'
        const searchResults = await apiCall<{
            messages: any[]
            total: number
        }>(`/messages?search=${encodeURIComponent(searchTerm)}&limit=3`)
        console.log(`   Found ${searchResults.total} messages containing "${searchTerm}"`)
        console.log('')

        // 8. List Group Chats Only
        console.log('8️⃣  List Group Chats')
        const groupChats = await apiCall<Array<{
            displayName: string
            unreadCount: number
        }>>('/chats?type=group&limit=5')
        console.log(`   Found ${groupChats.length} group chats:`)
        for (const group of groupChats) {
            console.log(`   - ${group.displayName} (${group.unreadCount} unread)`)
        }
        console.log('')

        // 9. Batch Send (uncomment to test)
        // console.log('9️⃣  Batch Send Messages')
        // const batchResults = await apiCall<Array<{
        //     to: string
        //     success: boolean
        // }>>('/send/batch', {
        //     method: 'POST',
        //     body: JSON.stringify({
        //         messages: [
        //             { to: TEST_RECIPIENT, content: 'Batch message 1' },
        //             { to: TEST_RECIPIENT, content: 'Batch message 2' }
        //         ]
        //     })
        // })
        // console.log(`   Sent ${batchResults.filter(r => r.success).length}/${batchResults.length} messages`)
        // console.log('')

        // 10. Watcher Status
        console.log('🔟 Watcher Status')
        const watcherStatus = await apiCall<{
            active: boolean
            connections: number
        }>('/watcher/status')
        console.log(`   Active: ${watcherStatus.active}`)
        console.log(`   Connections: ${watcherStatus.connections}`)
        console.log('')

        console.log('✅ All examples completed successfully!')

    } catch (error) {
        console.error('❌ Error:', error)
    }
}

// Run examples
main().catch(console.error)
