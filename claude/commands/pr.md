# /pr

Create a pull request using the repository's PR template if available.

## Instructions

1. Check for a PR template in the repository:
   - Look for `.github/pull_request_template.md`
   - Also check `.github/PULL_REQUEST_TEMPLATE.md`
   - Check for `.github/PULL_REQUEST_TEMPLATE/*.md` files

2. Draft the PR title and body:
   - Title: Use the branch name or recent commit messages as a basis
   - Body: If a PR template exists, use it as the structure
     - Fill in relevant sections based on the changes
     - Replace placeholder text with actual information
     - Keep checklist items and structure intact
   - If no template exists, create a comprehensive PR description with summary and changes

3. Create the PR using gh:
   ```bash
   gh pr create --title "PR title here" --body "$(cat <<'EOF'
   <PR body content here>
   EOF
   )"
   ```

4. Return the PR URL to the user

## Notes

- Do not mention Claude or AI in the PR description
- Preserve all template formatting, checklists, and structure
- If the template has placeholder text, replace it with actual values when possible
