# Agent Instructions

Whenever you make a major codebase change, update AGENTLOG.md.

Major changes include:
- switching frameworks, like AppKit to SwiftUI
- adding/removing dependencies
- changing project structure
- creating new modules/files
- changing auth, permissions, database, API, or build flow

Before major changes, briefly explain the plan.

After major changes, append this to AGENTLOG.md:

## YYYY-MM-DD HH:MM — Change title

### Summary
What changed.

### Why
Why the change was made.

### Files changed
- `path/to/file`: what changed

### Architecture impact
How this affects the app structure/runtime.

### How to test
Commands or manual steps.

### Follow-ups
Anything unfinished.