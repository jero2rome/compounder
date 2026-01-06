# Compounder Plugin Constitution

## Core Principles

### I. Shell-First Architecture
All plugin functionality must be implemented in shell scripts (bash/sh). This ensures:
- Maximum portability across systems with Claude Code
- No external runtime dependencies (Python, Node, etc.)
- Easy debugging and modification by users
- Transparent execution users can inspect

### II. State File Protocol
Loop state is managed through markdown files with YAML frontmatter:
- State files live in `.claude/compounder-{session_id}.local.md`
- Frontmatter contains structured metadata (iteration, max, promise)
- Body contains the prompt text
- Files are human-readable and editable

### III. Session Isolation
Each Claude Code session operates independently:
- State files are scoped by session ID
- Multiple loops can run in parallel across worktrees
- No shared global state between sessions
- Clean separation enables safe concurrent development

### IV. Minimal Output
Commands and hooks produce concise, actionable output:
- No verbose logging by default
- Error messages are clear and specific
- JSON output option for machine parsing
- Human-readable format for interactive use

### V. Fail-Safe Defaults
When in doubt, the plugin should fail safely:
- Missing state file = no active loop (not an error)
- Invalid state = report and stop (don't corrupt)
- Max iterations = hard stop (prevent runaway)
- Completion promise = exact match only

## Technical Standards

### File Locations
- Commands: `commands/*.md`
- Hooks: `hooks/hooks.json` + `hooks/*.sh`
- Scripts: `scripts/*.sh`
- Skills: `skills/*/skill.md`

### Script Requirements
- Use `#!/bin/bash` or `#!/bin/sh` shebang
- Exit codes: 0 = success, non-zero = error
- Use `CLAUDE_PROJECT_DIR` for absolute paths
- Parse frontmatter with grep/sed (no external tools)

### Hook Protocol
- Stop hooks output JSON: `{"decision": "block"|"allow", "reason": "..."}`
- Block decision feeds reason as next prompt
- Allow decision lets Claude exit normally

## Development Workflow

### Testing
- Manual testing via actual Claude Code sessions
- Test in isolated worktrees when possible
- Document test scenarios in command files

### Git Practices
- Feature branches: `feat/feature-name`
- Never auto-commit or auto-push
- Commit messages: conventional commits style

## Governance

This constitution governs all compounder plugin development. Changes require:
1. Documentation of the proposed change
2. Rationale for why current principles are insufficient
3. Impact analysis on existing functionality

**Version**: 1.0.0 | **Ratified**: 2026-01-06 | **Last Amended**: 2026-01-06
