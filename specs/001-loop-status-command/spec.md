# Feature Specification: Loop Status Command

**Feature Branch**: `001-loop-status-command`
**Created**: 2026-01-06
**Status**: Draft
**Input**: User description: "Add a /compounder:status command that displays current loop state including iteration count, max iterations, prompt preview, and completion promise"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Check Active Loop Status (Priority: P1)

A user has started a compound loop and wants to check its current progress without interrupting the loop. They run `/compounder:status` to see the current iteration, how many iterations remain, and what prompt is being executed.

**Why this priority**: This is the core use case - users need visibility into running loops to make decisions about whether to let them continue or cancel them.

**Independent Test**: Can be fully tested by starting a compound loop, running status command, and verifying output shows correct iteration count and prompt preview.

**Acceptance Scenarios**:

1. **Given** an active compound loop at iteration 3 of 10, **When** user runs `/compounder:status`, **Then** output shows "Iteration: 3 / 10" with prompt preview and completion promise
2. **Given** an active compound loop with unlimited iterations, **When** user runs `/compounder:status`, **Then** output shows "Iteration: 5 / unlimited"

---

### User Story 2 - Check Status When No Loop Active (Priority: P2)

A user wants to check if there's an active loop running. If no loop is active, they should receive a clear message indicating this rather than an error.

**Why this priority**: Important for user experience - prevents confusion when checking status on a session without an active loop.

**Independent Test**: Can be tested by running status command when no state file exists.

**Acceptance Scenarios**:

1. **Given** no active compound loop (no state file), **When** user runs `/compounder:status`, **Then** output shows "No active compound loop in this session."
2. **Given** a state file that was cleaned up after loop completion, **When** user runs `/compounder:status`, **Then** output shows "No active compound loop in this session."

---

### User Story 3 - JSON Output Format (Priority: P3)

A user wants to programmatically check loop status (e.g., from a monitoring script or another tool). They use `--json` flag to get machine-parseable output.

**Why this priority**: Power user feature - enables automation and tooling integration but not essential for basic usage.

**Independent Test**: Can be tested by running status command with --json flag and parsing output.

**Acceptance Scenarios**:

1. **Given** an active compound loop, **When** user runs `/compounder:status --json`, **Then** output is valid JSON with keys: active, iteration, max_iterations, completion_promise, prompt_preview, session_id, started_at
2. **Given** no active loop, **When** user runs `/compounder:status --json`, **Then** output is valid JSON with `{"active": false}`

---

### Edge Cases

- What happens when state file exists but is corrupted/invalid?
  - Should report error and suggest running `/cancel-compound` to clean up
- What happens when prompt text is very long (>500 chars)?
  - Should truncate with "..." indicator showing first 100 chars
- What happens with multiple sessions (different session IDs)?
  - Should only show status for current session (using COMPOUNDER_SESSION_ID)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Command MUST read state file from `.claude/compounder-{session_id}.local.md`
- **FR-002**: Command MUST parse YAML frontmatter to extract: active, iteration, max_iterations, completion_promise, session_id, started_at
- **FR-003**: Command MUST extract and display prompt text (body after frontmatter)
- **FR-004**: Command MUST truncate prompt preview to 100 characters with "..." indicator
- **FR-005**: Command MUST support `--json` flag for machine-readable output
- **FR-006**: Command MUST use `CLAUDE_PROJECT_DIR` environment variable for absolute path resolution
- **FR-007**: Command MUST use `COMPOUNDER_SESSION_ID` environment variable (defaulting to "default")
- **FR-008**: Command MUST gracefully handle missing state file (no error, informative message)
- **FR-009**: Command MUST detect and report corrupted state files

### Key Entities

- **State File**: Markdown file with YAML frontmatter containing loop configuration and body containing prompt text. Located at `.claude/compounder-{session_id}.local.md`
- **Session ID**: Identifier for isolating loops across parallel Claude Code sessions. From `COMPOUNDER_SESSION_ID` env var.

## Clarifications

### Q1: Output styling - Unicode vs ASCII?
**Answer**: Use ASCII-only for maximum terminal compatibility. No box-drawing characters.

### Q2: Emoji usage?
**Answer**: No emojis. Keep output plain text.

### Q3: Help flag support?
**Answer**: No `-h`/`--help` support needed. Keep command simple.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/compounder:status` on an active loop displays all metadata in under 1 second
- **SC-002**: JSON output from `--json` flag can be parsed by `jq` without errors
- **SC-003**: Status command never modifies the state file (read-only operation)
- **SC-004**: Output format matches the style of existing compounder commands (setup message format)
- **SC-005**: Output uses ASCII-only characters (no Unicode box-drawing, no emojis)
