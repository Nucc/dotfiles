# /commit

Create a commit from the latest changes since the last /clear. Do not mention Claude in the commit message. You can split the changes into logical groups and create commit for the groups. Try to use minimum number of commits.

## Model

sonnet

## Instructions

1. First, analyze the current changes:
   - Run `git status` to see all untracked and modified files
   - Run `git diff` to see both staged and unstaged changes
   - Run `git log --oneline -5` to see recent commit message style

2. Analyze all changes that will be included in the commit and draft commit messages:
   - Summarize the nature of the changes (new feature, enhancement, bug fix, refactoring, etc.)
   - Check for any sensitive information that shouldn't be committed
   - Draft concise commit messages that focus on the "why" rather than the "what"
   - Ensure messages accurately reflect the changes and their purpose

3. Group related changes into logical commits (minimize number of commits):
   - **Feature changes**: Backend + frontend for the same feature
   - **Configuration**: Routes, environment, Docker changes
   - **Translations**: Locale file updates
   - **Dependencies**: Package files and lock files

4. For each logical group:
   - Add relevant files to staging area with `git add`
   - Create commit using this format (never mention Claude):
   ```bash
   git commit -m "$(cat <<'EOF'
   Brief summary of what this accomplishes

   - Specific change or addition
   - Another specific change
   EOF
   )"
   ```

5. After creating commits:
   - Run `git status` to ensure commit succeeded
   - If commit fails due to pre-commit hooks, retry once to include automated changes

## Commit Message Guidelines

- Use imperative mood ("Add feature" not "Added feature")
- Keep summary line under 50 characters when possible
- Focus on business value and user impact
- Never mention Claude, AI, generators, or co-authors
- Use bullet points for multiple changes

## Example:
```
Add city management functionality

- Implement city creation with name validation
- Add admin interface for creating new cities
- Include success/error feedback for users
```
