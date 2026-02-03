---
description: Create a well-formatted commit
---

# Commit Changes

## What This Command Does

1. **MUST** run shellcheck before committing (MANDATORY)
2. **MUST** run tests before committing (MANDATORY)
3. Reviews changes and generates commit message
4. Creates the commit

## MANDATORY Pre-Commit Checks

**DO NOT COMMIT if any of these fail!**

### 1. Shellcheck (REQUIRED)

```bash
# Run shellcheck with -x flag to follow source files
shellcheck -x bin/who-ran-what
shellcheck -x lib/who-ran-what/**/*.sh
shellcheck -x tests/*.sh
```

**If shellcheck fails → FIX THE ISSUES FIRST, then retry commit.**

### 2. Tests (REQUIRED)

```bash
bash tests/run_all.sh
```

**If tests fail → FIX THE ISSUES FIRST, then retry commit.**

## Process (After Checks Pass)

### 1. Review Changes

```bash
git status
git diff --stat
```

### 2. Commit Message Format

```
type: brief description

- Detail 1
- Detail 2
```

#### Types

| Type     | Use For          |
| -------- | ---------------- |
| feat     | New feature      |
| fix      | Bug fix          |
| docs     | Documentation    |
| refactor | Code refactoring |
| test     | Adding tests     |
| chore    | Maintenance      |

### 3. Example Messages

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
```

## Rules

- **NEVER commit without running shellcheck first**
- **NEVER commit without running tests first**
- No Co-Authored-By lines
- No .env files
- Keep messages concise but descriptive

## Quick Pre-Commit Command

Run this before every commit:

```bash
shellcheck -x bin/who-ran-what lib/who-ran-what/**/*.sh tests/*.sh && bash tests/run_all.sh && echo "✅ Ready to commit!"
```
