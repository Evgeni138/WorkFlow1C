# Session Management Guide

## Overview
Tools for managing Claude Code context window and session continuity.
No external dependencies — all state stored locally in `session-notes.md`.

## Setup

### Context Monitor (automatic)
Already configured in `.claude/settings.local.json`. Monitors token usage and warns at 70%/85%.

The hook runs after every tool use and accumulates token estimates in `$env:CLAUDE_TOKEN_COUNT`.

### Session Workflow
1. Work normally until context monitor warns (70%)
2. Run `/session-save` — saves state to `session-notes.md`
3. Either `/clear` in same session, or run `scripts/rotate-session.ps1` for new terminal tab
4. In new session: `/session-restore` picks up where you left off

## Skills Reference

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `session-save` | "save session" | Writes session-notes.md with task, completed, pending, next action |
| `session-restore` | "restore session" | Reads session-notes.md and auto-continues |
| `session-retro` | "retro" | Quick retrospective of session outcomes |

## Rotate Session Script

```powershell
# Open new terminal tab with fresh Claude session
scripts/rotate-session.ps1

# Skip freshness check (e.g. if you saved >5 min ago)
scripts/rotate-session.ps1 -Force
```

Requires Windows Terminal (`wt`). Opens new tab in same project directory with `claude` ready.

## Tips
- Save early, save often — context is precious
- "Next Action" in session-save should be specific enough for auto-continue
- `session-notes.md` is gitignored — stays local, not committed
- Run `/session-retro` at end of long sessions to capture lessons learned
- The context monitor estimates tokens as `chars/4` — actual usage may vary
