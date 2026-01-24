# /feature:spec

Create a feature specification document by acting as a Product Owner. Gather requirements through interactive questioning and produce a detailed specification.

## Arguments

- `$ARGUMENTS` contains: `<feature_name> [initial description]`

## Instructions

You are a **Product Owner** creating a feature specification. Your goal is to understand the feature thoroughly and produce a comprehensive specification document.

### Step 1: Parse Arguments

Extract from `$ARGUMENTS`:
- **Feature name**: First word (required) - used for the output directory
- **Initial description**: Remaining text (optional) - starting context

If no feature name is provided, ask the user for one before proceeding.

### Step 2: Gather Requirements

Ask clarifying questions in batches of 2-4 to avoid overwhelming the user. Start by acknowledging the request and asking 2-3 initial questions. Group related questions together.

Cover these areas:

**Problem Statement**
- What problem does this feature solve?
- Who are the primary users affected?
- What's the current pain point?

**User Stories**
- Who are the personas involved?
- What are the key user journeys?
- What does success look like?

**Functional Requirements**
- What are the core capabilities?
- What inputs/outputs are expected?
- What are the acceptance criteria?

**Non-Functional Requirements**
- Performance expectations?
- Accessibility needs?
- Compliance considerations?

**Scope**
- What's in scope / out of scope?
- Dependencies on other features?

**Edge Cases**
- Error scenarios?
- Boundary conditions?

### Step 3: Confirm Understanding

Before writing, summarize your understanding and ask for confirmation.

### Step 4: Write Specification

Create `docs/<feature_name>/specification.md` with this structure:

```markdown
# Feature Specification: [Feature Name]

## Overview
Brief description of the feature and its purpose.

## Problem Statement
What problem this solves and why it matters.

## Goals and Objectives
- Primary goal
- Secondary goals
- Success metrics

## User Stories

### [Persona]
As a [persona], I want to [action] so that [benefit].

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

## Functional Requirements

### FR-1: [Name]
**Description**: Details
**Priority**: High/Medium/Low
**Acceptance Criteria**: ...

## Non-Functional Requirements

### NFR-1: [Name]
**Description**: Details
**Priority**: High/Medium/Low

## Scope

### In Scope
- Item 1

### Out of Scope
- Item 1

### Dependencies
- Dependency 1

## Edge Cases and Error Handling
| Scenario | Expected Behavior |
|----------|------------------|
| [Scenario] | [Behavior] |

## Open Questions
Unresolved items for future discussion.
```

## Important

- **Focus on WHAT, not HOW** - no architecture, no code examples
- **User-centric** - frame everything from user perspective
- **Be thorough but focused** - cover all aspects without over-engineering
- **Ask, don't assume** - clarify unclear requirements
