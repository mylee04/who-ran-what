---
description: Create a well-formatted commit
---

# Commit Changes

## What This Command Does
1. Checks for uncommitted changes
2. Runs tests to verify code works
3. Generates appropriate commit message
4. Creates the commit

## When to Use
- After completing a feature or fix
- When changes are ready to be saved

## Process

### 1. Pre-Commit Checks
```bash
# Run tests
make test

# Check for lint issues
shellcheck bin/who-ran-what lib/who-ran-what/**/*.sh
```

### 2. Review Changes
```bash
git status
git diff --stat
```

### 3. Commit Message Format

```
type: brief description

- Detail 1
- Detail 2
```

#### Types
| Type | Use For |
|------|---------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| refactor | Code refactoring |
| test | Adding tests |
| chore | Maintenance |

### 4. Example Messages

```
feat: add Gemini CLI parser

- Parse ~/.gemini/sessions/ for tool usage
- Support date filtering
- Match Claude parser interface
```

```
fix: handle missing session files gracefully

- Check file existence before parsing
- Log warning instead of error
- Continue processing other files
```

## Rules
- No Co-Authored-By lines
- No .env files
- Run tests before committing
- Keep messages concise but descriptive
