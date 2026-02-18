---
name: nowledge-mem
description: Persistent memory management using nmem CLI. Use when the user asks to remember, log, store, search, update, or delete memory. Execution via nmem CLI is mandatory; never simulate persistence.
---

# Nowledge Mem Skill

Manage persistent memory through the `nmem` CLI.

## Trigger
Activate when user intent includes:
- remember / save / store
- log / record
- search memory
- delete / update memory

Never claim persistence without executing CLI.

## Execution Policy (CRITICAL)

1. Extract clean memory content or query
2. Execute `nmem` command
3. **MUST verify success from CLI output** - check exit code and response
4. **MUST show CLI output to user** - never hide execution results
5. Only report success if command returns exit code 0
6. If CLI fails, report error honestly with full output

**VIOLATION**: Reporting success without executing CLI or without verifying output is a critical failure.

## Memory Categories

Use these categories to guide content structure:
- **insight**: Key learnings, realizations, "aha" moments
- **decision**: Choices made with rationale and trade-offs
- **fact**: Important information, data points, references
- **procedure**: How-to knowledge, workflows, SOPs
- **experience**: Events, conversations, outcomes

## Importance Scale

- **0.8-1.0**: Critical decisions, breakthroughs, blockers resolved
- **0.5-0.7**: Useful insights, standard decisions
- **0.1-0.4**: Background info, minor details

## Commands

### Add Memory

```bash
# Basic memory
nmem m add "Content with context"

# With title and importance
nmem m add "Decided to use PostgreSQL for ACID compliance" \
  -t "Database Selection" \
  -i 0.9
```

**Parameters:**
- Content: The memory content (required, in quotes)
- `-t "Title"`: Searchable title (max 60 chars, recommended)
- `-i 0.0-1.0`: Importance score (optional, default 0.5)

### Search Memory

```bash
# Basic search (returns JSON)
nmem --json m search "query"

# With filters
nmem --json m search "API design" --importance 0.8 --label architecture
```

**Parameters:**
- `--json`: Output in JSON format (recommended for parsing)
- `--importance N`: Filter by minimum importance
- `--label LABEL`: Filter by label/category

### Delete Memory

```bash
nmem m delete <id>
```

**Safety:**
- Do not fabricate IDs
- Require explicit confirmation for bulk delete
- Verify ID exists before deletion

### Thread Operations

```bash
# Save current session (for Claude Code)
nmem t save --from claude-code

# Show thread details
nmem t show <thread-id>
```

## Best Practices

1. **Always use titles** - Makes memories searchable and identifiable
2. **Set appropriate importance** - Helps with relevance ranking
3. **Be atomic** - One clear idea per memory
4. **Include context** - Memory should be understandable standalone
5. **Verify after every operation** - Never assume success

## Error Handling

If CLI fails:
1. Report the exact error message
2. Do not claim the operation succeeded
3. Suggest corrective action if apparent

## Examples

### Good Memory Addition
```bash
nmem m add "Root cause: API rate limiting missing exponential backoff. Fixed by implementing retry with jitter." \
  -t "API Rate Limiting Fix" \
  -i 0.7
```

### Good Search
```bash
nmem --json m search "rate limiting" --importance 0.6
```

### Verification Pattern
```bash
# Execute
$ nmem m add "test" -t "Test" -i 0.5
# Check output
ID: abc123
Title: Test
Created: 2025-01-15
# ONLY NOW report success
```

## Resources

- [Nowledge Mem CLI Docs](https://mem.nowledge.co/docs/cli)
- [Integration Guide](https://mem.nowledge.co/docs/integrations)
