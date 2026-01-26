# /feature:bug_fix

Fix a bug based on the provided bug information. Uses a preparation agent to analyze the issue and gather context, then fixes the problem in the main thread with regression test coverage.

## Arguments

- `$ARGUMENTS` contains: `<bug_description_or_issue_reference>`

## Instructions

You are fixing a bug. This command orchestrates five phases: investigation, fix implementation, test writing, test validation, optional refactoring, and fix summary.

### Phase 1: Investigation (Sub-agent)

Launch a Task agent with `subagent_type: "Explore"` to investigate the bug and gather context.

The investigation agent should:

1. **Understand the bug**
   - Parse the bug information from `$ARGUMENTS`
   - If the argument is a file path, read the file for bug details
   - If the argument is an issue number/URL, fetch the issue details
   - If the argument is a description, analyze it directly
   - If insufficient information, ask the user for clarification

2. **Reproduce the issue context**
   - Identify the entry points where the bug manifests
   - Trace the code path that leads to the bug
   - Understand the expected vs actual behavior

3. **Analyze the codebase**
   - Locate the source of the bug (root cause analysis)
   - Identify all files that need to be modified
   - Find related code that might be affected
   - Locate existing tests covering the affected area
   - Understand any edge cases or related scenarios

4. **Construct fix requirements**
   The agent should return a structured summary:
   ```
   ## Bug Summary
   [Brief description of the bug and its impact]

   ## Root Cause
   [Technical explanation of why the bug occurs]

   ## Affected Files
   - [file path]: [what's wrong and what needs to change]

   ## Related Code
   - [file path]: [how it relates to the bug]

   ## Existing Test Coverage
   - [test file]: [what it currently tests]
   - [gaps]: [what's not tested]

   ## Proposed Fix
   [High-level description of the fix approach]

   ## Risk Assessment
   - Impact: [High/Medium/Low]
   - Areas potentially affected: [list]

   ## Fix Sequence
   1. [First change]
   2. [Second change]
   ...
   ```

### Phase 2: Fix Implementation (Main Thread)

After receiving the investigation agent's analysis, implement the fix in the main thread.

**Implementation guidelines:**

1. **Follow the fix sequence** from the investigation analysis
2. **Make minimal changes** - fix only what's necessary
3. **Don't change unrelated code** - resist the urge to "improve" while fixing
4. **Follow existing patterns** - match the codebase style
5. **Keep the user informed** - explain what you're changing and why

**For each change:**
- Explain the change before making it
- Make the modification
- Verify the code compiles/lints (if applicable)

### Phase 3: Regression Test Writing (Main Thread)

After implementing the fix, write tests that:

1. **Reproduce the original bug**
   - Create a test case that would have caught this bug
   - The test should fail without the fix (conceptually verify this)

2. **Verify the fix**
   - Test the correct behavior after the fix
   - Cover the specific scenario from the bug report

3. **Cover edge cases**
   - Add tests for related edge cases identified during investigation
   - Prevent similar bugs from appearing in adjacent code paths

**Test writing guidelines:**

- Follow existing test patterns in the codebase
- Name tests descriptively (e.g., `test_should_not_crash_when_input_is_empty`)
- Include both positive and negative test cases
- Add comments explaining what each test verifies

### Phase 4: Test Validation (Sub-agent)

Launch a Task agent to run all tests.

The test agent should:
1. Run the full test suite (or relevant subset)
2. Report results back

**If tests pass:**
- Report success
- Proceed to refactoring phase

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

### Phase 5: Refactoring (Main Thread - Optional)

After tests pass, review whether refactoring is needed:

**Evaluate the fix:**
- Is the code readable and maintainable?
- Does it introduce any code smells?
- Is there duplicated logic that should be extracted?
- Are the variable/function names clear?

**If refactoring is needed:**
1. Make small, focused refactoring changes
2. Don't change behavior - only structure
3. Keep changes minimal - don't over-engineer
4. Re-run tests after refactoring

**If no refactoring is needed:**
- Skip directly to final validation

### Phase 6: Final Test Validation (Sub-agent)

If refactoring was performed, run the test suite again to ensure nothing broke.

**If tests fail:**
- Return to main thread to fix
- Re-run tests
- Repeat until passing

**If tests pass:**
- Proceed to completion

### Phase 7: Fix Summary (Main Thread)

Provide a comprehensive summary of the fix:

```
## Bug Fix Complete

### Bug Summary
[Brief description of what was wrong]

### Root Cause
[Technical explanation of why it happened]

### Fix Applied
[Description of the changes made]

### Files Modified
- [file path]: [what was changed]

### Tests Added
- [test file]: [what the new tests verify]

### Regression Prevention
[How the new tests prevent this bug from recurring]

### Verification
- [x] All tests passing
- [x] Bug scenario tested
- [x] Edge cases covered

### Next Steps
- Review the changes
- Run `/commit` to commit when ready
```

## Important

- **Understand before fixing** - Never fix a bug without understanding the root cause
- **Minimal changes** - Fix only what's broken, don't refactor unrelated code
- **Tests are mandatory** - Every bug fix must include regression tests
- **Fix failures in main thread** - User should see test fixes happening
- **Document the root cause** - Future developers should understand why the fix was needed
- **Ask if blocked** - If something is unclear or you hit a blocker, ask the user
- **Verify the fix addresses the original bug** - Don't just make tests pass, ensure the actual bug is fixed
