# Implementation Tasks: Loop Status Command

**Feature Branch**: `001-loop-status-command`
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Phase 1: Core Implementation

- [x] 1.1 Create status.sh script with basic structure
  - Create `scripts/status.sh` with shebang and set -euo pipefail
  - Parse --json flag from arguments
  - Set up environment variable defaults (CLAUDE_PROJECT_DIR, COMPOUNDER_SESSION_ID)
  - **Depends on**: None
  - **Requirement**: FR-005, FR-006, FR-007

- [x] 1.2 Implement state file detection
  - Construct state file path from env vars
  - Check if file exists
  - Output "No active compound loop" message when missing
  - Handle JSON vs human output modes for no-loop case
  - **Depends on**: 1.1
  - **Requirement**: FR-001, FR-008

- [x] 1.3 [P] Implement frontmatter parsing
  - Extract YAML frontmatter between --- markers using sed
  - Parse iteration, max_iterations, completion_promise, session_id, started_at
  - Handle quoted vs unquoted values
  - Validate numeric fields (iteration, max_iterations)
  - **Depends on**: 1.1
  - **Requirement**: FR-002, FR-009

- [x] 1.4 [P] Implement prompt extraction and truncation
  - Extract prompt body (everything after second ---)
  - Truncate to 100 characters if longer
  - Append "..." indicator when truncated
  - Replace newlines with spaces for single-line preview
  - **Depends on**: 1.1
  - **Requirement**: FR-003, FR-004

## Phase 2: Output Formatting

- [x] 2.1 Implement human-readable output
  - Format status with ASCII-only characters
  - Show "Iteration: X / Y" (or "unlimited" when max=0)
  - Show completion promise, session ID, started timestamp
  - Show truncated prompt preview
  - **Depends on**: 1.3, 1.4
  - **Requirement**: FR-002, FR-003, SC-004, SC-005

- [x] 2.2 [P] Implement JSON output
  - Use jq to construct valid JSON
  - Include all fields: active, iteration, max_iterations, completion_promise, session_id, started_at, prompt_preview
  - Ensure output is parseable by jq
  - **Depends on**: 1.3, 1.4
  - **Requirement**: FR-005, SC-002

## Phase 3: Command Integration

- [x] 3.1 Create command definition
  - Create `commands/status.md` with frontmatter
  - Set description, argument-hint, allowed-tools
  - Follow existing command pattern from compound-loop.md
  - Add execution instructions in body
  - **Depends on**: 2.1, 2.2
  - **Requirement**: FR-001

- [x] 3.2 Make script executable
  - chmod +x scripts/status.sh
  - **Depends on**: 3.1
  - **Requirement**: None (operational)

## Phase 4: Testing & Validation

- [x] 4.1 Test no-loop scenario
  - Ensure no state file exists
  - Run /compounder:status
  - Verify "No active compound loop" message
  - Run /compounder:status --json
  - Verify {"active": false} output
  - **Depends on**: 3.2
  - **Requirement**: SC-003

- [x] 4.2 Test active loop scenario
  - Start loop with /compound-loop
  - Run /compounder:status
  - Verify iteration count, prompt preview displayed
  - Verify output is ASCII-only
  - **Depends on**: 4.1
  - **Requirement**: SC-001, SC-004, SC-005

- [x] 4.3 Test JSON output validity
  - Run /compounder:status --json | jq .
  - Verify JSON parses without errors
  - Verify all expected fields present
  - **Depends on**: 4.2
  - **Requirement**: SC-002

- [x] 4.4 Test edge cases
  - Test with unlimited iterations (max_iterations: 0)
  - Test with long prompt (>100 chars) to verify truncation
  - Test with multi-line prompt
  - **Depends on**: 4.3
  - **Requirement**: FR-004

## Notes

- `[P]` indicates tasks that can be parallelized with siblings
- Tasks 1.3 and 1.4 can be developed in parallel after 1.1
- Tasks 2.1 and 2.2 can be developed in parallel after 1.3/1.4
- All testing tasks are sequential to build confidence incrementally
