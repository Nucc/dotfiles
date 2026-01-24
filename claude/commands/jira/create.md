# Create Jira Ticket

Create a Jira ticket in the TALK project based on the following request:

{{prompt}}

Instructions:
1. Analyze the request to determine if the user wants to:
   - Create a ticket based on the prompt itself
   - Create a ticket based on our conversation history (look for phrases like "based on our conversation", "from this chat", "for what we discussed", etc.)

2. Generate appropriate ticket details:
   - Summary: A concise, descriptive title (max 255 characters)
   - Description: A detailed description in Jira markdown format
   - Issue Type: Determine the appropriate type (Story, Bug, Task, etc.) - default to "Task" if unclear
   - Priority: Determine priority if mentioned (Highest, High, Medium, Low, Lowest) - default to "Medium"

3. If using conversation history, include:
   - Context of what was discussed
   - Any code changes made
   - Technical details and decisions
   - Any remaining work or follow-ups

4. Create the ticket using the Jira REST API:
   - Verify JIRA_ACCESS_TOKEN and JIRA_EMAIL environment variables are set
   - Use JIRA_URL env var if set, otherwise derive from JIRA_EMAIL domain (e.g., lpapp@zendesk.com → https://zendesk.atlassian.net)
   - API endpoint: POST /rest/api/3/issue
   - Project key: "TALK"
   - Use Basic Auth with JIRA_EMAIL as username and JIRA_ACCESS_TOKEN as password

5. Example API call structure:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -u "$JIRA_EMAIL:$JIRA_ACCESS_TOKEN" \
  "$JIRA_URL/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": {"key": "TALK"},
      "summary": "Ticket summary",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [...]
      },
      "issuetype": {"name": "Task"}
    }
  }'
```

6. After creating the ticket, display:
   - The ticket key (TALK-XXX)
   - The ticket URL
   - A brief confirmation message

IMPORTANT:
- Jira API v3 uses Atlassian Document Format (ADF) for description, not markdown
- Convert markdown to ADF format for the description field
- Properly escape JSON in the API payload
- Handle errors gracefully and provide clear error messages
- Parse the API response to extract the ticket key and construct the URL
