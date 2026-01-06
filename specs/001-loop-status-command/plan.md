# Implementation Plan: Loop Status Command

**Branch**: `001-loop-status-command` | **Date**: 2026-01-06 | **Spec**: [spec.md](./spec.md)

## Summary

Add a `/compounder:status` command that displays current compound loop state (iteration, max, prompt preview, completion promise) by reading the existing state file. Follows shell-first architecture with ASCII-only output.

## Technical Context

**Language/Version**: Bash (POSIX-compatible where possible)
**Primary Dependencies**: Standard Unix tools (grep, sed, awk, jq)
**Storage**: Reads existing state file (`.claude/compounder-{session_id}.local.md`)
**Testing**: Manual testing via Claude Code sessions
**Target Platform**: macOS, Linux (any system with bash + jq)
**Project Type**: Claude Code plugin (shell scripts + markdown commands)
**Constraints**: Read-only operation, ASCII-only output, <1 second execution

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| Shell-First Architecture | PASS | Implemented entirely in bash |
| State File Protocol | PASS | Reads existing format, no modifications |
| Session Isolation | PASS | Uses COMPOUNDER_SESSION_ID |
| Minimal Output | PASS | Concise status, JSON option for automation |
| Fail-Safe Defaults | PASS | Missing file = no loop (not error) |

## Project Structure

### Documentation (this feature)

```text
specs/001-loop-status-command/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Implementation tasks (next phase)
```

### Source Code (repository root)

```text
commands/
├── compound-loop.md     # Existing
├── cancel-compound.md   # Existing
├── status.md            # NEW - Command definition

scripts/
├── setup-compound-loop.sh  # Existing
├── status.sh               # NEW - Status script
```

## Component Design

### 1. Command Definition (`commands/status.md`)

Follows existing pattern from `compound-loop.md`:

```yaml
---
description: "Show current compound loop status"
argument-hint: "[--json]"
allowed-tools: ["Bash(COMPOUNDER_SESSION_ID=* ${CLAUDE_PLUGIN_ROOT}/scripts/status.sh)"]
hide-from-slash-command-tool: "true"
---
```

### 2. Status Script (`scripts/status.sh`)

**Inputs**:
- `CLAUDE_PROJECT_DIR` env var (project root, default: `.`)
- `COMPOUNDER_SESSION_ID` env var (session isolation, default: `default`)
- `$ARGUMENTS` - optional `--json` flag

**Algorithm**:
```
1. Parse --json flag from arguments
2. Construct state file path: ${CLAUDE_PROJECT_DIR}/.claude/compounder-${SESSION_ID}.local.md
3. If file doesn't exist:
   - Human: "No active compound loop in this session."
   - JSON: {"active": false}
   - Exit 0
4. Parse YAML frontmatter (between --- markers) using sed/grep
5. Extract fields: iteration, max_iterations, completion_promise, session_id, started_at
6. Extract prompt body (everything after second ---)
7. Truncate prompt to 100 chars if longer, append "..."
8. Output in requested format
```

**Human Output Format**:
```
Compounder Loop Active
----------------------
Iteration:  3 / 10
Promise:    DONE
Session:    abc123
Started:    2026-01-06T10:30:00Z
Prompt:     Implement the authentication module with JWT tokens...
```

**JSON Output Format**:
```json
{
  "active": true,
  "iteration": 3,
  "max_iterations": 10,
  "completion_promise": "DONE",
  "session_id": "abc123",
  "started_at": "2026-01-06T10:30:00Z",
  "prompt_preview": "Implement the authentication..."
}
```

## Error Handling

| Scenario | Human Output | JSON Output | Exit Code |
|----------|--------------|-------------|-----------|
| No state file | "No active compound loop in this session." | `{"active": false}` | 0 |
| Corrupted frontmatter | "Error: State file corrupted. Run /cancel-compound to clean up." | `{"active": false, "error": "corrupted"}` | 1 |
| Missing CLAUDE_PROJECT_DIR | Uses `.` as default | Uses `.` as default | 0 |

## Files to Create

| File | Description |
|------|-------------|
| `commands/status.md` | Command definition triggering status.sh |
| `scripts/status.sh` | Shell script reading state and outputting status |

## Testing Strategy

Manual test scenarios:
1. `/compounder:status` with no active loop -> "No active compound loop"
2. Start loop, run `/compounder:status` -> shows iteration/prompt
3. `/compounder:status --json` -> valid JSON parseable by jq
4. Test with max_iterations: 0 (unlimited) -> shows "unlimited"
5. Test with prompt >100 chars -> truncated with "..."
