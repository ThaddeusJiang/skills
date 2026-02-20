---
name: gh-cli
description: GitHub CLI operations for issues and pull requests. Use when creating, reading, updating, or closing issues and PRs. Always verify operations after execution.
---

# GitHub CLI Skill

Manage GitHub issues and pull requests using `gh` CLI.

---

## Capability

- **Issues**: Create, List, View, Update, Close, Reopen
- **Pull Requests**: Create, List, View, Update, Merge, Close
- **Verification**: Always verify operations after execution

## When to Use

- Create or update GitHub issues
- Create or manage pull requests
- Query repository status
- Interact with GitHub from EUE

---

## Prerequisites

```bash
# Check if gh is installed
gh --version

# Authenticate (if not already)
gh auth status
# If not authenticated:
gh auth login
```

---

## Issues

### Create Issue

```bash
# Create issue
gh issue create --title "Bug: Something broken" --body "Description here" --repo owner/repo

# With labels
gh issue create --title "Feature request" --body "Description" --label "enhancement" --repo owner/repo

# With assignee
gh issue create --title "Task" --body "Description" --assignee @me --repo owner/repo
```

**⚠️ MUST VERIFY:**
```bash
# Get the issue number from output, then verify
gh issue view <number> --repo owner/repo
```

### List Issues

```bash
# List open issues
gh issue list --repo owner/repo

# List all issues (including closed)
gh issue list --repo owner/repo --state all

# Filter by label
gh issue list --repo owner/repo --label "bug"

# Filter by assignee
gh issue list --repo owner/repo --assignee @me
```

### View Issue

```bash
gh issue view <number> --repo owner/repo

# View as JSON (for parsing)
gh issue view <number> --repo owner/repo --json number,title,state,url
```

### Update Issue

```bash
# Add a comment
gh issue comment <number> --repo owner/repo --body "Comment text"

# Add labels
gh issue edit <number> --repo owner/repo --add-label "bug,help wanted"

# Remove labels
gh issue edit <number> --repo owner/repo --remove-label "enhancement"

# Change title
gh issue edit <number> --repo owner/repo --title "New title"

# Change assignee
gh issue edit <number> --repo owner/repo --add-assignee @me
```

**⚠️ MUST VERIFY:**
```bash
gh issue view <number> --repo owner/repo
```

### Close Issue

```bash
# Close with comment
gh issue close <number> --repo owner/repo --comment "Fixed in #123"

# Close without comment
gh issue close <number> --repo owner/repo
```

**⚠️ MUST VERIFY:**
```bash
gh issue view <number> --repo owner/repo --json state
# Should return: {"state": "CLOSED"}
```

### Reopen Issue

```bash
gh issue reopen <number> --repo owner/repo
```

---

## Pull Requests

### Create PR

```bash
# Create PR from current branch
gh pr create --title "Feature: Add new functionality" --body "Description here" --repo owner/repo

# Create PR from specific branch
gh pr create --base main --head feature-branch --title "Title" --body "Body" --repo owner/repo

# Create draft PR
gh pr create --draft --title "WIP: Feature" --body "Work in progress" --repo owner/repo
```

**⚠️ MUST VERIFY:**
```bash
# Get the PR number from output, then verify
gh pr view <number> --repo owner/repo
```

### List PRs

```bash
# List open PRs
gh pr list --repo owner/repo

# List all PRs (including closed/merged)
gh pr list --repo owner/repo --state all

# Filter by author
gh pr list --repo owner/repo --author @me

# Filter by label
gh pr list --repo owner/repo --label "review needed"
```

### View PR

```bash
gh pr view <number> --repo owner/repo

# View as JSON
gh pr view <number> --repo owner/repo --json number,title,state,url,headRefName,baseRefName
```

### Update PR

```bash
# Add a comment
gh pr comment <number> --repo owner/repo --body "Looks good to me!"

# Request review
gh pr edit <number> --repo owner/repo --add-reviewer username

# Add labels
gh pr edit <number> --repo owner/repo --add-label "review needed"

# Convert to draft
gh pr ready <number> --repo owner/repo --undo

# Mark as ready for review
gh pr ready <number> --repo owner/repo
```

**⚠️ MUST VERIFY:**
```bash
gh pr view <number> --repo owner/repo
```

### Merge PR

```bash
# Merge with merge commit
gh pr merge <number> --repo owner/repo --merge

# Merge with squash
gh pr merge <number> --repo owner/repo --squash

# Merge with rebase
gh pr merge <number> --repo owner/repo --rebase

# Delete branch after merge
gh pr merge <number> --repo owner/repo --delete-branch
```

**⚠️ MUST VERIFY:**
```bash
gh pr view <number> --repo owner/repo --json state,mergedAt
# Should return: {"state": "MERGED", "mergedAt": "..."}
```

### Close PR

```bash
# Close with comment
gh pr close <number> --repo owner/repo --comment "Closing this PR"

# Close without comment
gh pr close <number> --repo owner/repo
```

**⚠️ MUST VERIFY:**
```bash
gh pr view <number> --repo owner/repo --json state
# Should return: {"state": "CLOSED"}
```

---

## Verification Pattern

**CRITICAL: After every create/update/close operation, MUST verify:**

```bash
# For Issues
gh issue view <number> --repo owner/repo --json number,title,state,url

# For PRs  
gh pr view <number> --repo owner/repo --json number,title,state,url

# Check if operation succeeded
# - number exists
# - state is expected (OPEN, CLOSED, MERGED)
# - url is accessible
```

---

## Common Workflows

### Report Bug Workflow

```bash
# 1. Create issue
ISSUE_URL=$(gh issue create --title "Bug: ..." --body "..." --repo owner/repo)

# 2. Extract issue number
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')

# 3. Verify
gh issue view "$ISSUE_NUM" --repo owner/repo

# 4. Report result to user
echo "✅ Issue #$ISSUE_NUM created: $ISSUE_URL"
```

### Feature PR Workflow

```bash
# 1. Create branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add . && git commit -m "feat: add new feature"
git push -u origin feature/new-feature

# 3. Create PR
PR_URL=$(gh pr create --title "Feature: ..." --body "..." --repo owner/repo)

# 4. Extract PR number
PR_NUM=$(echo "$PR_URL" | grep -o '[0-9]*$')

# 5. Verify
gh pr view "$PR_NUM" --repo owner/repo

# 6. Report result
echo "✅ PR #$PR_NUM created: $PR_URL"
```

---

## Error Handling

```bash
# Check if repo exists
gh repo view owner/repo --json name

# Check if issue exists
gh issue view <number> --repo owner/repo 2>&1 || echo "Issue not found"

# Check if user has write access
gh repo view owner/repo --json viewerPermission
```

---

## Testing Repository

Use https://github.com/ThaddeusJiang/skills for testing.

**⚠️ IMPORTANT:**
- Test only on your own repositories
- Do not affect other users' issues/PRs
- Clean up test issues/PRs after testing
- Use `--repo ThaddeusJiang/skills` explicitly

---

## Examples

### Example: Create and Verify Issue

```bash
# Create issue
OUTPUT=$(gh issue create \
  --title "Test: gh-cli skill" \
  --body "Testing gh-cli skill functionality" \
  --repo ThaddeusJiang/skills)

echo "Output: $OUTPUT"

# Extract issue number
ISSUE_NUM=$(echo "$OUTPUT" | grep -oE '[0-9]+$')
echo "Issue number: $ISSUE_NUM"

# Verify
gh issue view "$ISSUE_NUM" --repo ThaddeusJiang/skills --json number,title,state,url

# Close test issue
gh issue close "$ISSUE_NUM" --repo ThaddeusJiang/skills --comment "Test completed"

# Verify closure
gh issue view "$ISSUE_NUM" --repo ThaddeusJiang/skills --json state
```

---

## Files

- `SKILL.md` - This file (skill definition)

---

## Notes

1. **Always use `--repo owner/repo`** to be explicit about target repository
2. **Always verify** after create/update/close operations
3. **Report both success and failure** honestly to user
4. **Clean up test data** after testing
5. **Parse JSON output** for reliable data extraction: `--json field1,field2`
