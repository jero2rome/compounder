---
name: workflow
description: Use when the user wants to execute tasks autonomously, run compounder on a tasks.md file, start autonomous development, compound through a task list, or implement tasks iteratively. Guides autonomous task execution using compound loops.
---

# Workflow Skill

Orchestrates autonomous task execution using compounder's iterative loop mechanism.

## Quick Start

When user has tasks ready for autonomous execution:

```
/compounder:compound-loop "Execute tasks from tasks.md. Mark completed with [X]. Run tests after each." --max-iterations 20 --completion-promise "ALL_TASKS_COMPLETE"
```

## Phase Detection

Before starting, detect project state:

1. **Check for tasks.md**: Look for `tasks.md`, `.specify/specs/*/tasks.md`, or similar
   - If found with `- [ ]` uncompleted tasks: Ready for execution
   - Count tasks to estimate iterations (2-3 per task)

2. **Check for plan.md/spec.md**: If no tasks.md exists
   - Guide user to create tasks first (manually or via speckit)

## Launching Compounder

### Calculate Parameters

```
iterations = (uncompleted_tasks * 2) + 5  # buffer for debugging
completion_promise = "ALL_TASKS_COMPLETE" or custom from user
```

### Prompt Template

Build a prompt that:
1. References the tasks file explicitly
2. Instructs to follow task order (phases if present)
3. Mark tasks `[X]` as completed
4. Run verification after each task
5. Output `<promise>COMPLETION</promise>` only when truly done

### Example Invocations

**For a tasks.md with 10 tasks:**
```
/compounder:compound-loop "Execute all tasks in tasks.md following TDD. After each task: mark [X], run tests. When ALL tasks complete and tests pass, output <promise>ALL_TASKS_COMPLETE</promise>" --max-iterations 25 --completion-promise "ALL_TASKS_COMPLETE"
```

**For a single complex task:**
```
/compounder:run-task "Implement user authentication" --iterations 10 --done-when "AUTH_WORKING"
```

## Speckit Integration

If speckit commands are available in the project:

| Phase | Command | Output |
|-------|---------|--------|
| Specify | `/speckit.specify` | spec.md |
| Plan | `/speckit.plan` | plan.md |
| Tasks | `/speckit.tasks` | tasks.md |
| Execute | `/compounder:compound-loop` | Implementation |

## Completion Signals

The compound loop ends when:
- `<promise>COMPLETION_PROMISE</promise>` is output (and TRUE)
- Max iterations reached
- `/compounder:cancel-compound` is run

## Monitoring Progress

```bash
# Check current iteration
head -10 .claude/compounder-*.local.md

# View task completion
grep -E "^\- \[.\]" tasks.md
```
