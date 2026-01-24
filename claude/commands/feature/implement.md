# /feature:implement

Implement a user story based on the specification and architecture documents. Uses a preparation agent to gather context, then implements in the main thread with test validation.

## Arguments

- `$ARGUMENTS` contains: `<path_to_story_file>`

## Instructions

You are implementing a user story. This command orchestrates five phases: preparation, implementation, testing, refactoring, and final validation.

### Phase 1: Preparation (Sub-agent)

Launch a Task agent with `subagent_type: "Explore"` to gather implementation context.

The preparation agent should:

1. **Read the story file** from `$ARGUMENTS`
   - If no path provided, ask the user for one
   - Extract the story's acceptance criteria

2. **Find and read related documents**
   - Look for `specification.md` in the same folder or parent folder
   - Look for `architecture.md` in the same folder or parent folder
   - If not found, ask the user for paths

3. **Analyze the codebase**
   - Identify files that need to be created or modified
   - Find existing patterns to follow
   - Locate relevant tests
   - Understand the technology stack

4. **Construct implementation requirements**
   The agent should return a structured summary:
   ```
   ## Story Summary
   [Brief description of what needs to be implemented]

   ## Acceptance Criteria
   [List from the story file]

   ## Architecture Guidance
   [Relevant sections from architecture.md]

   ## Files to Create/Modify
   - [file path]: [what to do]

   ## Patterns to Follow
   - [existing file]: [pattern to replicate]

   ## Test Files
   - [existing test files to update]
   - [new test files to create]

   ## Implementation Sequence
   1. [First step]
   2. [Second step]
   ...
   ```

### Phase 2: Implementation (Main Thread)

After receiving the preparation agent's analysis, implement the feature in the main thread.

**Implementation guidelines:**

1. **Follow the sequence** from the preparation analysis
2. **Write tests alongside code** - don't leave tests for the end
3. **Follow existing patterns** - match the codebase style
4. **Small, incremental changes** - implement one piece at a time
5. **Keep the user informed** - explain what you're doing as you go

**For each component:**
- Create/modify the implementation file
- Create/modify the corresponding test file
- Verify the code compiles/lints (if applicable)

### Phase 3: Test Validation (Sub-agent)

After implementation is complete, launch a Task agent to run all tests.

The test agent should:
1. Run the full test suite (or relevant subset)
2. Report results back

**If tests pass:**
- Report success
- Summarize what was implemented
- Mark the story as ready for review

**If tests fail:**
- Return to main thread with failure details
- Fix the failing tests
- Re-run test validation
- Repeat until all tests pass

### Test Commands

The test agent should detect the project type and run appropriate commands:

| Project Type | Test Command |
|--------------|--------------|
| Node.js | `npm test` or `yarn test` |
| Python | `pytest` or `python -m pytest` |
| Go | `go test ./...` |
| Rust | `cargo test` |
| Ruby | `bundle exec rspec` |
| Java/Kotlin | `./gradlew test` or `mvn test` |

If unsure, ask the user for the test command.

### Phase 4: Refactoring (Main Thread)

After tests pass, review and refactor the implementation:

**Refactoring checklist:**

1. **Remove duplication** - Extract repeated code into functions/methods
2. **Simplify logic** - Reduce complexity, flatten nested conditions
3. **Improve naming** - Ensure variables, functions, classes have clear names
4. **Clean up** - Remove dead code, unused imports, debug statements
5. **Consistency** - Match codebase conventions and patterns
6. **SOLID principles** - Check for single responsibility, proper abstractions

**Guidelines:**
- Make small, focused refactoring changes
- Don't change behavior - only structure
- Keep changes minimal - don't over-engineer
- If no refactoring needed, that's fine - skip to test validation

### Phase 5: Final Test Validation (Sub-agent)

After refactoring, run the test suite again to ensure nothing broke.

**If tests fail:**
- Return to main thread to fix
- Re-run tests
- Repeat until passing

**If tests pass:**
- Proceed to completion

### Completion

When all tests pass after refactoring:

1. **Update the story status** - Edit the story file to mark it as Done:
   ```markdown
   ## Status
   - [x] Done
   ```

2. **Provide a summary:**

```
## Implementation Complete

### Story Status
- [story file path] updated to Done

### Files Created
- [list of new files]

### Files Modified
- [list of modified files]

### Tests
- [X] All tests passing
- New tests added: [count]

### Acceptance Criteria
- [x] Criterion 1
- [x] Criterion 2
...

### Next Steps
- Review the changes
- Run `/commit` to commit when ready
```

## Important

- **Tests are mandatory** - Never finish without passing tests
- **Fix failures in main thread** - User should see test fixes happening
- **Don't skip acceptance criteria** - Each criterion must be addressed
- **Follow the architecture** - Don't deviate from architecture.md decisions
- **Ask if blocked** - If something is unclear or you hit a blocker, ask the user
- **Incremental implementation** - Don't try to implement everything at once
- **Refactor after tests pass** - Clean up code before marking complete
- **Update story status** - Always mark the story as Done when complete
