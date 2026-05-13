# Graph Report - .  (2026-05-13)

## Corpus Check
- Corpus is ~36,753 words - fits in a single context window. You may not need a graph.

## Summary
- 542 nodes · 918 edges · 22 communities (20 shown, 2 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 36 edges (avg confidence: 0.75)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Outgoing Promises|Outgoing Promises]]
- [[_COMMUNITY_Test Coverage|Test Coverage]]
- [[_COMMUNITY_Message Sending|Message Sending]]
- [[_COMMUNITY_Test Fixtures|Test Fixtures]]
- [[_COMMUNITY_Plugin System|Plugin System]]
- [[_COMMUNITY_SDK Core|SDK Core]]
- [[_COMMUNITY_API Server|API Server]]
- [[_COMMUNITY_Utilities Attachments|Utilities Attachments]]
- [[_COMMUNITY_Workflow Concepts|Workflow Concepts]]
- [[_COMMUNITY_Attachment Downloads|Attachment Downloads]]
- [[_COMMUNITY_REST API Types|REST API Types]]
- [[_COMMUNITY_REST API Clients|REST API Clients]]
- [[_COMMUNITY_Errors Watcher|Errors Watcher]]
- [[_COMMUNITY_Database Access|Database Access]]
- [[_COMMUNITY_Message Chains|Message Chains]]
- [[_COMMUNITY_Temp File Management|Temp File Management]]
- [[_COMMUNITY_Promise Matching|Promise Matching]]
- [[_COMMUNITY_Webhook Example|Webhook Example]]
- [[_COMMUNITY_Semaphore Tests|Semaphore Tests]]
- [[_COMMUNITY_SSE Example|SSE Example]]

## God Nodes (most connected - your core abstractions)
1. `IMessageSDK` - 24 edges
2. `IMessageDatabase` - 21 edges
3. `IMessageAPIClient` - 16 edges
4. `MessageSender` - 16 edges
5. `MessageChain` - 14 edges
6. `MessagePromise` - 13 edges
7. `Message` - 12 edges
8. `iMessage REST API` - 12 edges
9. `OutgoingMessageManager` - 11 edges
10. `Express App` - 11 edges

## Surprising Connections (you probably didn't know these)
- `ChatId Format Matching` --semantically_similar_to--> `MessagePromise Test Coverage`  [INFERRED] [semantically similar]
  agenttext_api/README.md → agenttext_api/__tests__/10-message-promise.test.ts
- `OutgoingMessageManager Test Coverage` --conceptually_related_to--> `POST /send`  [INFERRED]
  agenttext_api/__tests__/11-outgoing-manager.test.ts → agenttext_api/API-README.md
- `Dual CJS ESM Bundle Configuration` --conceptually_related_to--> `Cross-Runtime iMessage SDK`  [INFERRED]
  agenttext_api/tsup.config.ts → agenttext_api/README.md
- `Express App` --implements--> `GET /messages/unread`  [EXTRACTED]
  agenttext_api/api-server.ts → agenttext_api/API-README.md
- `SendMessageRequest` --shares_data_with--> `POST /send`  [EXTRACTED]
  agenttext_api/api-types.ts → agenttext_api/API-README.md

## Hyperedges (group relationships)
- **REST Endpoint Surface** — api_readme_get_messages_endpoint, api_readme_post_send_endpoint, api_readme_get_chats_endpoint [EXTRACTED 1.00]
- **SSE Watcher State Flow** — api_server_watcher_active_state, api_server_active_connections, api_readme_sse_streaming [EXTRACTED 1.00]
- **SDK Behavior Test Suite** — 03_database_query_tests, 05_chain_processing_tests, 06_sdk_core_tests [EXTRACTED 1.00]
- **SDK Examples Exercise Public API Surface** — examples_sdk_send_file, examples_sdk_send_group, examples_sdk_query_messages, examples_sdk_list_chats, examples_sdk_auto_reply_chain, index_public_api_surface [EXTRACTED 1.00]
- **REST API Examples Cover Core Messaging Workflows** — api_client_python, api_client_typescript, api_sse_streaming, api_webhook_auto_reply [EXTRACTED 1.00]
- **Outgoing Message Confirmation Pipeline** — examples_sdk_get_sent_message, message_promise_outgoing_tracker, message_promise_matching, outgoing_manager_pending_promises, database_row_to_message [INFERRED 0.82]
- **SDK Send Flow** — sdk_imessage_sdk, sender_message_sender, plugins_plugin_manager, sender_outgoing_confirmation [EXTRACTED 1.00]
- **Attachment Temporary File Lifecycle** — sender_attachment_resolution, download_image_pipeline, applescript_sandbox_bypass, temp_file_manager [INFERRED 0.85]
- **Message Observation Pipeline** — watcher_message_watcher, watcher_polling_deduplication, plugins_plugin_lifecycle_hooks, watcher_webhook_delivery [EXTRACTED 1.00]

## Communities (22 total, 2 thin omitted)

### Community 0 - "Outgoing Promises"
Cohesion: 0.06
Nodes (34): DatabaseAdapter, MessagePromiseOptions, MessagePromiseRejection, OutgoingMessageManager, SDKDependencies, MessageCallback, WatcherEvents, message (+26 more)

### Community 1 - "Test Coverage"
Cohesion: 0.05
Nodes (53): IMessageError Test Coverage, Validation and Semaphore Test Coverage, IMessageDatabase Query Test Coverage, Plugin Lifecycle Test Coverage, MessageChain Test Coverage, IMessageSDK Core Test Coverage, Integration Workflow Test Coverage, listChats Test Coverage (+45 more)

### Community 2 - "Message Sending"
Cohesion: 0.1
Nodes (30): SendError(), MessageSender, SendOptions, SendToGroupOptions, task(), calculateFileDelay(), checkIMessageStatus(), checkMessagesApp() (+22 more)

### Community 3 - "Test Fixtures"
Cohesion: 0.06
Nodes (29): invalidDb, yesterday, chain, chain1, chain2, executeSpy, message, sendSpy (+21 more)

### Community 4 - "Plugin System"
Cohesion: 0.06
Nodes (33): SendResult, definePlugin(), Plugin, PluginHooks, PluginManager, PluginMetadata, COLORS, LEVELS (+25 more)

### Community 5 - "SDK Core"
Cohesion: 0.09
Nodes (15): IMessageSDK, asRecipient(), AsyncHandler, AsyncPredicate, Handler, hasMinDigits(), isURL(), Mapper (+7 more)

### Community 6 - "API Server"
Cohesion: 0.05
Nodes (22): activeConnections, app, data, filter, heartbeat, options, sdk, server (+14 more)

### Community 7 - "Utilities Attachments"
Cohesion: 0.11
Nodes (33): Recipient Validation, HTTP URL Detection, AppleScript Execution, Attachment Sandbox Bypass, Messages AppleScript Generation, Attachment Helper Functions, Chat ID Utilities, Message Content Validation (+25 more)

### Community 8 - "Workflow Concepts"
Cohesion: 0.09
Nodes (30): Python REST API Client Example, TypeScript REST API Client Example, REST API SSE Streaming Example, REST API Auto Reply Bot Example, MessageChain Processing Pipeline, MessageChain Reply Routing, SDK Error Message Constants, Attachment Path and Metadata Mapping (+22 more)

### Community 9 - "Attachment Downloads"
Cohesion: 0.11
Nodes (20): attachmentExists(), AUDIO_EXTENSIONS, AudioExtension, downloadAttachment(), getAttachmentExtension(), getAttachmentSize(), IMAGE_EXTENSIONS, ImageExtension (+12 more)

### Community 10 - "REST API Types"
Cohesion: 0.08
Nodes (23): ApiClientConfig, ApiError, ApiInfo, ApiResponse, Attachment, BatchSendRequest, BatchSendResult, ChatQueryParams (+15 more)

### Community 11 - "REST API Clients"
Cohesion: 0.16
Nodes (7): IMessageAPIClient, main(), Simple client for the iMessage REST API, Send multiple messages, Get messages with optional filters, List chats with optional filters, Start message watcher

### Community 12 - "Errors Watcher"
Cohesion: 0.13
Nodes (9): ConfigError(), ErrorCode, IMessageError, PlatformError(), WebhookError(), MessageWatcher, error, regularError (+1 more)

### Community 13 - "Database Access"
Cohesion: 0.19
Nodes (6): bool(), execAsync, IMessageDatabase, initDatabase(), str(), DatabaseError()

### Community 15 - "Temp File Management"
Cohesion: 0.21
Nodes (4): DEFAULT_CONFIG, TEMP_DIR, TempFileManager, TempFileManagerConfig

### Community 17 - "Webhook Example"
Cohesion: 0.39
Nodes (7): BOT_CONFIG, main(), Message, processMessage(), sendMessage(), startWatcher(), streamMessages()

### Community 18 - "Semaphore Tests"
Cohesion: 0.4
Nodes (4): result, results, semaphore, start

### Community 19 - "SSE Example"
Cohesion: 0.6
Nodes (4): main(), SSEMessage, startWatcher(), streamMessages()

## Ambiguous Edges - Review These
- `REST API SSE Streaming Example` → `Outgoing Pending Promise Manager`  [AMBIGUOUS]
  agenttext_api/examples/api-sse-example.ts · relation: conceptually_related_to
- `MessageChain Processing Pipeline` → `Unified SDK Error Model`  [AMBIGUOUS]
  agenttext_api/src/core/chain.ts · relation: conceptually_related_to
- `Attributed Body Text Extraction` → `Unified SDK Error Model`  [AMBIGUOUS]
  agenttext_api/src/core/database.ts · relation: conceptually_related_to

## Knowledge Gaps
- **186 isolated node(s):** `app`, `sdk`, `filter`, `options`, `activeConnections` (+181 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `REST API SSE Streaming Example` and `Outgoing Pending Promise Manager`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `MessageChain Processing Pipeline` and `Unified SDK Error Model`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Attributed Body Text Extraction` and `Unified SDK Error Model`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `IMessageSDK` connect `SDK Core` to `Outgoing Promises`, `Attachment Downloads`, `Test Fixtures`, `Plugin System`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Why does `MessageSender` connect `Message Sending` to `Outgoing Promises`, `Test Fixtures`, `Plugin System`, `SDK Core`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `IMessageDatabase` connect `Database Access` to `Outgoing Promises`, `Attachment Downloads`, `Test Fixtures`, `Plugin System`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **What connects `app`, `sdk`, `filter` to the rest of the system?**
  _186 weakly-connected nodes found - possible documentation gaps or missing edges._