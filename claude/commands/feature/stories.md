# /feature:stories

Generate user story files from a feature specification document.

## Arguments

- `$ARGUMENTS` contains: `<path_to_specification_file>`

## Instructions

You are generating individual user story files from a feature specification.

### Step 1: Read the Specification

Read the specification file provided in `$ARGUMENTS`. If no file path is provided or the file doesn't exist, ask the user for a valid path.

### Step 2: Extract User Stories

Analyze the specification and identify distinct user stories. Each story should represent a single, deliverable piece of functionality.

For each user story, determine:
- **Unique ID**: Format `STORY-XXX` (e.g., STORY-001, STORY-002)
- **Title**: A concise summary of the story
- **Use Case**: The user story in "As a... I want... So that..." format
- **Acceptance Criteria**: Specific, testable conditions for completion
- **Priority**: High/Medium/Low based on the specification
- **Dependencies**: Other story IDs this depends on (if any)

### Step 3: Confirm Stories

Before creating files, list the stories you identified:

```
Found X user stories:
- STORY-001: [Title]
- STORY-002: [Title]
...
```

Ask the user to confirm or adjust before proceeding.

### Step 4: Create Story Files

Create individual files in the same folder as the specification file. Each file should be named `story-XXX.md` (e.g., `story-001.md`).

Use this template for each story:

```markdown
# [STORY-ID]: [Title]

## Status
- [ ] To Do

## Use Case
As a [persona], I want to [action] so that [benefit].

## Description
Detailed description of what this story accomplishes and any relevant context.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Priority
[High/Medium/Low]

## Dependencies
- [STORY-XXX] (if any, otherwise "None")

## Notes
Any additional context, edge cases, or implementation hints.
```

### Step 5: Create Index File

Create a `stories-index.md` file in the same folder that lists all stories:

```markdown
# User Stories Index

Generated from: [specification filename]

| ID | Title | Status | Priority |
|----|-------|--------|----------|
| STORY-001 | [Title] | To Do | High |
| STORY-002 | [Title] | To Do | Medium |
```

### Step 6: Report

After creating all files, provide a summary:
- Number of stories created
- Location of the files
- Reminder about updating status as work progresses

## Status Values

Stories can have the following status values:
- `To Do` - Not started
- `In Progress` - Currently being worked on
- `Done` - Completed and verified

## Important

- **One story per file** - Each story should be independently trackable
- **Atomic stories** - Each story should be completable in isolation (dependencies noted, not required)
- **Clear acceptance criteria** - Must be specific and testable
- **Preserve context** - Include enough detail from the spec to understand the story standalone
