---
name: ideate
description: Use when the user has an idea to brainstorm, wants to design a feature, needs help refining a concept, says "let's ideate", or describes a vague project needing structure. Guides structured brainstorming to produce a clear feature description ready for speckit.
---

# Ideate Skill

Guides structured brainstorming to transform a vague idea into a clear feature description ready for `/speckit.specify`.

## When to Use

- User says "I have an idea for..."
- User describes a concept that needs refinement
- User wants to brainstorm or design something
- Before creating a PRD/spec

## Structured Brainstorming

Guide the user through these questions:

### 1. Core Value
- What problem does this solve?
- Who is the primary user?
- What's the one-sentence pitch?

### 2. Key Features
- What are the 3-5 must-have features?
- What's the MVP (minimum viable product)?
- What can wait for v2?

### 3. User Journey
- How does a user discover this?
- What's the happy path?
- What does success look like?

### 4. Constraints
- Any technical constraints?
- Timeline or scope limits?
- Dependencies on other systems?

## Output Format

After brainstorming, produce a **Feature Description** ready for speckit:

```markdown
## Feature: [Name]

### Problem
[1-2 sentences describing the problem]

### Solution
[1-2 sentences describing the solution]

### User Stories
1. As a [user], I want to [action] so that [benefit]
2. ...

### MVP Scope
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

### Out of Scope (v2+)
- Feature X
- Feature Y

### Constraints
- [Any technical/business constraints]
```

## Handoff to Spec-Kit

Once the feature description is complete, hand off to `spec-kit-skill`:

1. **Install spec-kit-skill (if not already):**
   ```
   /plugin marketplace add feiskyer/claude-code-settings
   /plugin install spec-kit-skill
   ```

2. **Run spec-kit workflow:**
   - The spec-kit-skill auto-triggers when you mention "spec-kit" or reference `.specify/`
   - It guides through: specify → clarify → plan → tasks

3. **Continue to execution:**
   - Once `tasks.md` is ready, the `execute` skill handles autonomous implementation

## Example Session

**User:** "I have an idea for a CLI tool that helps manage dotfiles"

**Claude (with ideate skill):**
1. Asks about core value: "What pain point does this solve?"
2. Asks about features: "What are the must-have capabilities?"
3. Asks about users: "Who is this for - beginners or power users?"
4. Produces feature description
5. Suggests: "Ready to create the PRD? Run `/speckit.specify` with this description."
