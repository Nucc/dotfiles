# Claude Code Custom Commands and Agents

Custom slash commands and agents for Claude Code, stored in dotfiles for portability.

## Structure

```
claude/
├── commands/           # Slash commands
│   ├── commit.md       # /commit command
│   ├── pr.md           # /pr command
│   ├── feature/
│   │   └── spec.md     # /feature:spec command
│   └── jira/
│       └── create.md   # /jira:create command
└── hooks/              # Hook scripts (optional)
```

## Installation

Run the install script to copy files to `~/.claude/`:

```bash
./install.sh
```

This copies:
- `dotfiles/claude/commands/*` → `~/.claude/commands/`
- `dotfiles/claude/agents/*` → `~/.claude/agents/`
- `dotfiles/claude/hooks/*` → `~/.claude/hooks/`

**Important:**
- Files with the same name **will be overwritten**
- Your `~/.claude/settings.json` (with API keys) is **never touched**
- Existing files with different names are preserved

## Commands

### /commit

Create git commits from current changes.

```
/commit
```

**Behavior:**
- Analyzes staged and unstaged changes
- Groups related changes into logical commits
- Uses imperative mood, focuses on "why" not "what"
- Never mentions Claude/AI in commit messages

### /pr

Create a pull request using the repository's PR template.

```
/pr
```

**Behavior:**
- Looks for PR templates in `.github/`
- Fills in template sections based on changes
- Creates PR via `gh pr create`
- Returns the PR URL

### /jira:create

Create a Jira ticket from a prompt or conversation.

```
/jira:create <description>
```

**Behavior:**
- Creates tickets in the TALK project
- Can use conversation history for context
- Uses Jira REST API with ADF format
- Requires `JIRA_EMAIL` and `JIRA_ACCESS_TOKEN` env vars

### /feature:spec

Create a feature specification from a prompt.

```
/feature:spec <feature_name> [initial description]
```

**Example:**
```
/feature:spec user-auth Add OAuth2 login support
```

**Behavior:**
1. Acts as a Product Owner
2. Asks clarifying questions about the feature
3. Creates `docs/<feature_name>/specification.md`

**Output focuses on:**
- Problem statement and goals
- User stories with acceptance criteria
- Functional and non-functional requirements
- Scope boundaries
- Edge cases

**Does NOT include:**
- Architecture decisions
- Code examples
- Technical implementation details

## Agents

### feature-spec-agent

Product Owner agent for requirements gathering. Can be spawned via Task tool for complex specification work.

## Adding New Commands

1. Create `commands/<namespace>/<name>.md` for `/namespace:name`
2. Or `commands/<name>.md` for `/<name>`
3. Follow existing patterns for structure
