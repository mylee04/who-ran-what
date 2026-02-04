---
description: Code review for shell scripts
---

# Code Review

## What This Command Does

1. Reviews changed files for issues
2. Checks security, best practices, and style
3. Provides actionable feedback

## When to Use

- Before merging a PR
- After completing a feature
- When unsure about code quality

## Process

### 1. Identify Changed Files

```bash
git diff --name-only HEAD~1
# or
git diff --name-only main
```

### 2. Review Each File

For each shell script, check:

#### Security

- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] Safe command execution

#### Shell Best Practices

- [ ] Quoted variables
- [ ] Local function variables
- [ ] Error handling

#### Code Quality

- [ ] Clear naming
- [ ] Focused functions
- [ ] Necessary comments only

### 3. Provide Feedback

Format:

```
## [filename]

### Issues
- Line X: [issue] → [fix]

### Suggestions
- [optional improvement]

### Verdict
[APPROVE / NEEDS CHANGES]
```

## Severity Levels

- **BLOCK**: Security issue or critical bug
- **NEEDS CHANGES**: Best practice violation
- **APPROVE**: Code is ready to merge
