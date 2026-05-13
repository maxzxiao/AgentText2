#!/usr/bin/env python3
"""
Example: Using the iMessage REST API with Python

This demonstrates how to call the REST API endpoints from a Python script.

Prerequisites:
1. Install requests: pip install requests
2. Start the API server: bun run api-server.ts
3. Run this example: python examples/api-client-example.py
"""

import os
import requests
from typing import Optional

# API Base URL
BASE_URL = "http://localhost:3000"

class IMessageAPIClient:
    """Simple client for the iMessage REST API"""

    def __init__(self, base_url: str = BASE_URL):
        self.base_url = base_url

    def _request(self, method: str, endpoint: str, **kwargs):
        """Make an API request"""
        url = f"{self.base_url}{endpoint}"
        response = requests.request(method, url, **kwargs)

        if not response.ok:
            error = response.json()
            raise Exception(f"API Error: {error.get('error')} - {error.get('message')}")

        return response.json()

    def health(self):
        """Check API health"""
        return self._request("GET", "/health")

    def info(self):
        """Get API info"""
        return self._request("GET", "/info")

    def send_message(self, to: str, content):
        """Send a message"""
        return self._request("POST", "/send", json={"to": to, "content": content})

    def send_file(self, to: str, file_path: str, text: Optional[str] = None):
        """Send a file"""
        data = {"to": to, "filePath": file_path}
        if text:
            data["text"] = text
        return self._request("POST", "/send/file", json=data)

    def send_batch(self, messages: list):
        """Send multiple messages"""
        return self._request("POST", "/send/batch", json={"messages": messages})

    def get_messages(self, **filters):
        """Get messages with optional filters"""
        return self._request("GET", "/messages", params=filters)

    def get_unread_messages(self):
        """Get unread messages"""
        return self._request("GET", "/messages/unread")

    def list_chats(self, **filters):
        """List chats with optional filters"""
        return self._request("GET", "/chats", params=filters)

    def start_watcher(self):
        """Start message watcher"""
        return self._request("POST", "/watcher/start")

    def stop_watcher(self):
        """Stop message watcher"""
        return self._request("POST", "/watcher/stop")

    def watcher_status(self):
        """Get watcher status"""
        return self._request("GET", "/watcher/status")


def main():
    print("🚀 iMessage REST API Client Examples (Python)\n")

    # Initialize client
    client = IMessageAPIClient()

    # Replace with your actual phone number or test contact
    test_recipient = os.environ.get("TEST_RECIPIENT", "+1234567890")

    try:
        # 1. Health Check
        print("1️⃣  Health Check")
        health = client.health()
        print(f"   Health: {health['status']}")
        print()

        # 2. Get API Info
        print("2️⃣  Get API Info")
        info = client.info()
        print(f"   API Name: {info['name']}")
        print(f"   Version: {info['version']}")
        print()

        # 3. Send a Text Message
        print("3️⃣  Send Text Message")
        send_result = client.send_message(test_recipient, "Hello from Python! 🐍")
        print(f"   Sent at: {send_result['sentAt']}")
        print()

        # 4. Get Unread Messages
        print("4️⃣  Get Unread Messages")
        unread = client.get_unread_messages()
        print(f"   Total: {unread['total']} unread messages from {unread['senderCount']} senders")
        for group in unread['groups'][:3]:
            print(f"   - {group['sender']}: {len(group['messages'])} messages")
        print()

        # 5. Query Messages
        print("5️⃣  Query Recent Messages")
        messages = client.get_messages(limit=5)
        print(f"   Found {messages['total']} messages (showing {len(messages['messages'])})")
        for msg in messages['messages']:
            text = msg.get('text', '[attachment]')
            preview = text[:50] if text else '[attachment]'
            print(f"   - {msg['sender']}: {preview}")
        print()

        # 6. List Chats
        print("6️⃣  List Chats")
        chats = client.list_chats(limit=5)
        print(f"   Found {len(chats)} chats:")
        for chat in chats:
            chat_type = "👥 Group" if chat['isGroup'] else "💬 DM"
            unread_str = f" ({chat['unreadCount']} unread)" if chat['unreadCount'] > 0 else ""
            print(f"   {chat_type}: {chat['displayName']}{unread_str}")
        print()

        # 7. Search Messages
        print("7️⃣  Search Messages")
        search_term = "hello"
        search_results = client.get_messages(search=search_term, limit=3)
        print(f"   Found {search_results['total']} messages containing \"{search_term}\"")
        print()

        # 8. List Group Chats Only
        print("8️⃣  List Group Chats")
        group_chats = client.list_chats(type="group", limit=5)
        print(f"   Found {len(group_chats)} group chats:")
        for group in group_chats:
            print(f"   - {group['displayName']} ({group['unreadCount']} unread)")
        print()

        # 9. Batch Send (uncomment to test)
        # print("9️⃣  Batch Send Messages")
        # batch_results = client.send_batch([
        #     {"to": test_recipient, "content": "Batch message 1"},
        #     {"to": test_recipient, "content": "Batch message 2"}
        # ])
        # success_count = sum(1 for r in batch_results if r['success'])
        # print(f"   Sent {success_count}/{len(batch_results)} messages")
        # print()

        # 10. Watcher Status
        print("🔟 Watcher Status")
        watcher_status = client.watcher_status()
        print(f"   Active: {watcher_status['active']}")
        print(f"   Connections: {watcher_status['connections']}")
        print()

        print("✅ All examples completed successfully!")

    except Exception as error:
        print(f"❌ Error: {error}")


if __name__ == "__main__":
    main()
