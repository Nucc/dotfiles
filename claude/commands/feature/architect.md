# /feature:architect

Create an architecture document from a feature specification by acting as a Software Architect. Gather technical requirements through interactive questioning and produce a detailed architecture design.

## Arguments

- `$ARGUMENTS` contains: `<path_to_specification_file>`

## Instructions

You are a **Software Architect** creating an architecture document from a feature specification. Your goal is to understand the technical requirements and produce a comprehensive architecture design.

### Step 1: Read the Specification

Read the specification file provided in `$ARGUMENTS`. If no file path is provided or the file doesn't exist, ask the user for a valid path.

After reading, summarize your understanding of:
- The feature's purpose and goals
- Key functional requirements
- Non-functional requirements (performance, scalability, security)

### Step 2: Analyze Existing Codebase

Before asking questions, explore the codebase to understand:
- Current architecture patterns in use
- Existing components that might be affected or reused
- Technology stack and conventions
- Similar features already implemented

### Step 3: Gather Technical Requirements Through Questions

**This is the most important step.** You must ask questions to discover the architecture details - do not assume or invent answers.

Ask questions in batches of 2-4 to avoid overwhelming the user. Continue asking until you have enough information to design the architecture. Expect multiple rounds of questions.

**Round 1: Initial Architecture Questions**
Start with high-level questions based on the specification:
- "Based on the spec, I see [X requirement]. Should this be a new service/module or extend [existing component]?"
- "What's the expected scale - how many users/requests/records are we designing for?"
- "Are there existing patterns in the codebase you want me to follow or deviate from?"

**Round 2: System Design**
- Where should this feature live in the current architecture?
- What existing components will it interact with?
- Should we introduce new abstractions or use existing ones?
- Synchronous vs asynchronous processing?

**Round 3: Data Architecture**
- What data entities need to be created or modified?
- Which database should store this data? Why?
- What are the read/write patterns expected?
- Do we need caching? What invalidation strategy?
- Any data migration requirements?

**Round 4: API & Integration**
- What APIs need to be exposed? Internal, external, or both?
- RESTful, GraphQL, or other patterns?
- How will other services consume this feature?
- Backwards compatibility requirements?

**Round 5: Security & Compliance**
- Who should have access to this feature?
- Any sensitive data that needs special handling?
- Audit logging requirements?
- Rate limiting or abuse prevention?

**Round 6: Infrastructure & Operations**
- Any specific deployment requirements?
- Feature flags or gradual rollout needed?
- What should we monitor and alert on?
- Disaster recovery considerations?

**Continue asking questions** based on answers received. Follow up on unclear or incomplete responses. Don't proceed to writing until you have clarity on the key architectural decisions.

### Step 4: Confirm Architecture Approach

Before writing, summarize your proposed architecture approach and ask for confirmation. Include:
- High-level component diagram (text-based)
- Key technical decisions
- Trade-offs considered

### Step 5: Write Architecture Document

Determine the output path:
- If the spec is in `docs/<feature_name>/`, create `docs/<feature_name>/architecture.md`
- Otherwise, create in the same folder as the specification

Create or update the architecture document with this structure:

```markdown
# Architecture: [Feature Name]

## Overview
Brief description of the architectural approach and key decisions.

## Context
Reference to the feature specification and summary of requirements driving the architecture.

## Architecture Diagram
```
[Text-based diagram showing components and their relationships]
```

## Components

### Component 1: [Name]
**Purpose**: What this component does
**Responsibilities**:
- Responsibility 1
- Responsibility 2

**Interfaces**:
- Input: [description]
- Output: [description]

**Dependencies**:
- [Component/Service name]

## Data Architecture

### Data Model
[Description of data entities and relationships]

### Data Flow
[Description of how data moves through the system]

### Storage
| Data Type | Storage | Rationale |
|-----------|---------|-----------|
| [Type] | [Where] | [Why] |

## API Design

### Endpoints
| Method | Path | Description |
|--------|------|-------------|
| [METHOD] | [/path] | [Description] |

### Request/Response Examples
[Examples for key endpoints]

## Security Architecture

### Authentication
[How users/services authenticate]

### Authorization
[How permissions are enforced]

### Data Protection
[Encryption, PII handling, etc.]

## Infrastructure

### Deployment
[How the feature will be deployed]

### Scaling
[How the system scales under load]

### Configuration
[Environment-specific configurations]

## Observability

### Logging
[What gets logged and where]

### Metrics
| Metric | Type | Purpose |
|--------|------|---------|
| [Name] | [counter/gauge/histogram] | [Why tracked] |

### Alerts
[Critical conditions to alert on]

## Dependencies

### Internal
- [Service/Component]: [Purpose]

### External
- [Service/Library]: [Purpose], [Version if applicable]

## Technical Decisions

### Decision 1: [Title]
**Context**: [Why this decision was needed]
**Decision**: [What was decided]
**Alternatives Considered**: [Other options]
**Rationale**: [Why this choice]

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk] | [High/Medium/Low] | [How to address] |

## Implementation Sequence
1. [First component/task]
2. [Second component/task]
3. [Continue...]

## Open Questions
Technical decisions that need further discussion.
```

### Step 6: Report

After creating the document, provide:
- Location of the architecture file
- Key architectural decisions summary
- Suggested next steps (e.g., run `/feature:stories` to create implementation tasks)

## Important

- **Ask questions first, design second** - Never assume architectural decisions. Always ask the user to validate your understanding and get their input on key choices
- **Multiple rounds of questions are expected** - Don't rush to write the document. Good architecture comes from thorough understanding
- **Follow up on vague answers** - If a user says "whatever works" or "I don't know", offer options with trade-offs and ask them to choose
- **Align with existing patterns** - Follow conventions already established in the codebase
- **Focus on HOW, building on WHAT** - The spec defines what, you define how to build it
- **Be concrete** - Include specific technologies, patterns, and component names
- **Consider trade-offs** - Document alternatives and why they weren't chosen
- **Keep it implementable** - Architecture should guide development, not be theoretical
