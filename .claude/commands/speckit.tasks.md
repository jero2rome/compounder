---
description: Generate actionable tasks using Claude's native analysis, then structure into tasks.md format.
handoffs:
  - label: Analyze For Consistency
    agent: speckit.analyze
    prompt: Run a project analysis for consistency
    send: true
  - label: Implement Project
    agent: speckit.implement
    prompt: Start the implementation in phases
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Philosophy

This command uses **Claude Code's native task breakdown capabilities** to analyze the plan and create tasks, then structures the output into spec-kit's tasks.md format. Claude should think naturally about implementation order, dependencies, and complexity rather than following procedural rules.

## Outline

### 1. Setup

Run `.specify/scripts/bash/check-prerequisites.sh --json` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list.

### 2. Load Context

Read from FEATURE_DIR:
- **Required**: plan.md (architecture, decisions, tech stack), spec.md (user stories)
- **Optional**: data-model.md, contracts/, research.md, quickstart.md

### 3. Analyze Implementation (Claude-Native Thinking)

**CRITICAL**: Use your native analysis capabilities to understand the implementation:

**Think through the implementation naturally:**
- What needs to be built first? (foundations, dependencies)
- What can be built in parallel? (independent components)
- What are the risky/complex parts? (may need more time)
- What are the integration points? (where things connect)
- What needs testing? (critical paths)

**Consider the codebase context:**
- Use the **Task tool with subagent_type=Explore** if needed to understand:
  - Existing patterns to follow
  - Where new code should live
  - What existing code to leverage
  - Potential conflicts or dependencies

**Natural task breakdown:**
- Let tasks emerge from understanding, not from rules
- Group related work naturally
- Consider developer workflow (what feels right to implement together)
- Identify obvious parallelization opportunities

Based on your analysis, create tasks that:
- Are specific enough to execute without additional context
- Include clear file paths where work happens
- Have logical ordering (dependencies before dependents)
- Mark parallelizable tasks with [P]

Use `.specify/templates/tasks-template.md` as the output structure.

### 5. Write tasks.md

Structure your naturally-derived tasks into the template format:
- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundations (prerequisites for features)
- **Phase 3+**: Feature phases (by user story priority)
- **Final Phase**: Polish & integration

### 6. Report

Output:
- Path to generated tasks.md
- Total task count
- Key dependencies identified
- Parallelization opportunities
- Suggested MVP scope

The tasks.md should be immediately executable - each task must be specific enough that Claude can complete it without additional context.

## Task Format (for consistency)

Use this format for tasks to enable automated tracking:

```text
- [ ] T001 [P?] Description with file path
```

- **Checkbox**: `- [ ]` for uncompleted, `- [x]` for completed
- **Task ID**: Sequential (T001, T002...) for reference
- **[P] marker**: Optional, indicates parallelizable
- **Description**: Clear action with file path

**Examples**:
- `- [ ] T001 Create project structure per plan.md`
- `- [ ] T005 [P] Implement auth middleware in src/middleware/auth.py`

## Key Principles

- **Claude-first**: Let tasks emerge from natural analysis, not procedural rules
- **Context-aware**: Consider existing codebase patterns when defining tasks
- **Executable**: Each task should be completable without additional context
- **Logical order**: Dependencies before dependents, foundations before features
