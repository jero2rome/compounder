---
description: Execute deep planning using Claude Code's native plan mode, then structure output into plan.md.
handoffs:
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Philosophy

This command uses **Claude Code's native planning capabilities first**, then structures the output into spec-kit's plan.md format. The procedural checklist approach is replaced with deep exploration and analysis.

## Outline

### 1. Setup

Run `.specify/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH.

### 2. Load Context

Read these files to understand what needs to be planned:
- FEATURE_SPEC (the spec.md for this feature)
- `.specify/memory/constitution.md` (project principles)

### 3. Enter Deep Planning Mode

**CRITICAL**: Use the `EnterPlanMode` tool to initiate Claude Code's native deep planning.

This triggers algorithmic exploration rather than procedural template-filling:
- Explore the codebase to understand existing patterns
- Analyze multiple architectural approaches
- Evaluate trade-offs (performance, maintainability, complexity)
- Identify risks and mitigation strategies
- Consider how this feature integrates with existing code

### 4. Deep Planning Analysis

While in plan mode, explore and analyze:

**Architecture Exploration**
- What are the possible approaches to implement this feature?
- What patterns already exist in the codebase that should be followed?
- What are the trade-offs between different approaches?
- Which approach best fits the project's constitution?

**Technical Analysis**
- What dependencies are needed? Are there existing ones to leverage?
- What is the data model? How does it relate to existing entities?
- What APIs/interfaces are needed?
- What are the performance implications?

**Risk Assessment**
- What could go wrong?
- What are the unknowns that need research?
- What assumptions are being made?
- What are the dependencies on external systems?

**Integration Analysis**
- How does this feature connect to existing code?
- What existing tests need updating?
- What documentation needs updating?

### 5. Capture Planning Decisions

After exploration, document your findings:

**Decisions Made**
- Architecture approach selected and WHY
- Technologies/dependencies chosen and WHY
- Patterns to follow and WHY

**Alternatives Rejected**
- Other approaches considered
- Why they were not selected
- Under what conditions they might be reconsidered

**Risks Identified**
- Technical risks with mitigation plans
- Integration risks
- Performance risks

### 6. Exit Plan Mode

Use `ExitPlanMode` when you have:
- Explored the codebase thoroughly
- Analyzed multiple approaches
- Made architectural decisions with rationale
- Identified risks and mitigations
- Determined the implementation strategy

### 7. Structure into plan.md

Take your planning analysis and structure it into the plan.md template at IMPL_PLAN:

- **Summary**: Primary requirement + chosen technical approach with rationale
- **Technical Context**: Concrete decisions (not "NEEDS CLARIFICATION" - resolve unknowns during planning)
- **Constitution Check**: Validate against project principles
- **Project Structure**: Concrete file layout based on codebase analysis
- **Decisions & Rationale**: NEW SECTION - document why choices were made
- **Alternatives Considered**: NEW SECTION - what else was evaluated
- **Risks & Mitigations**: NEW SECTION - identified risks and plans

### 8. Generate Supporting Artifacts

Based on your deep planning analysis, create:
- `research.md` - Document any research findings
- `data-model.md` - Entity definitions (if applicable)
- `contracts/` - API specifications (if applicable)

### 9. Report

Output:
- Branch name
- Path to plan.md
- Key architectural decisions made
- Risks identified
- Ready for `/speckit.tasks`

## Key Principles

- **Claude-first**: Use native planning capabilities, not procedural checklists
- **Explore before deciding**: Analyze codebase patterns before making architectural choices
- **Document rationale**: Every decision needs a "why"
- **Resolve unknowns**: Don't leave "NEEDS CLARIFICATION" - research during planning
- **Constitution alignment**: Ensure decisions follow project principles
