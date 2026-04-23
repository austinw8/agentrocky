# agentrocky

A macOS desktop companion app that puts an animated pixel-art character on your screen — powered by [Claude Code](https://claude.ai/code).

Rocky walks back and forth along the top of your Dock. Click him to open a retro terminal-style chat window and talk to Claude directly from your desktop. When a task finishes, he celebrates with a little jazz dance.

---

## Features

- **Animated sprite** — Rocky walks across the bottom of your screen with smooth 60fps motion and 8fps sprite animation
- **Jazz celebrations** — Rocky dances when Claude finishes a task, and spontaneously jazzes out every 15–45 seconds while idle
- **Speech bubbles** — Rocky shows status messages while working ("rocky building", "rocky do big science") and celebrates when done ("rocky done!", "fist my bump")
- **Retro terminal chat** — click Rocky to open a 420×520 dark-themed popover with color-coded output:
  - Green for assistant responses
  - Cyan for tool calls
  - Red for errors
- **Persistent session** — the Claude Code session survives the chat window being opened and closed
- **Live tool call visibility** — see exactly what Claude is doing as it runs commands and uses tools
- **Background accessory** — runs without a Dock icon, floating above all windows on every Space

## Requirements

- macOS 13+
- Xcode 15+
- [Claude Code CLI](https://claude.ai/code) installed at one of:
  - `~/.local/bin/claude`
  - `~/.npm-global/bin/claude`
  - `/opt/homebrew/bin/claude`
  - `/usr/local/bin/claude`
  - `/usr/bin/claude`

## Quick Start

```bash
git clone https://github.com/snehas/agentrocky.git
cd agentrocky
open agentrocky.xcodeproj
```

Then press `Cmd+R` in Xcode to build and run. Rocky appears above your Dock — click him to start chatting.

The session runs with your home directory (`~`) as the working context, so Claude can run commands and tools relative to `~`.

## Sprite States

| State | Frames | Trigger |
|-------|--------|---------|
| Standing | `stand.png` | Chat window is open |
| Walking | `walkleft1.png`, `walkleft2.png` | Default movement (bounces at screen edges) |
| Jazz | `jazz1.png`, `jazz2.png`, `jazz3.png` | Task complete or random idle celebration |

## Architecture

| File | Purpose |
|------|---------|
| `agentrockyApp.swift` | App entry point; 60fps walk loop, 8fps sprite animation, jazz trigger logic |
| `RockyState.swift` | Shared `@Observable` state — position, direction, chat visibility, speech bubbles |
| `ClaudeSession.swift` | Spawns and manages the `claude` subprocess; parses stream-JSON over stdin/stdout |
| `RockyView.swift` | Sprite rendering, popover attachment, speech bubble overlay |
| `ChatView.swift` | Terminal-style chat UI with scrollable, color-coded message history |

## How It Works

agentrocky launches Claude Code as a subprocess with stream-JSON I/O:

```
claude -p --output-format stream-json --input-format stream-json --verbose --dangerously-skip-permissions
```

Messages are serialized as newline-delimited JSON and streamed over stdin/stdout. The app parses Claude's output in real time, updating the chat log and triggering animations based on task lifecycle events (tool calls in progress, task complete).

The floating window is a transparent, borderless `NSPanel` set to always float above other windows and appear on every Space — no Dock icon, no menu bar presence.
