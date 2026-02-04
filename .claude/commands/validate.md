---
description: Validate shell script syntax and best practices
---

# Validate Scripts

## What This Command Does

1. Runs shellcheck on all shell scripts
2. Reports any warnings or errors
3. Suggests fixes for common issues

## When to Use

- Before committing changes
- After writing new shell code
- When debugging script issues

## Process

### 1. Run shellcheck

```bash
# Check main executable
shellcheck bin/who-ran-what

# Check all library scripts
shellcheck lib/who-ran-what/**/*.sh

# Check test files
shellcheck tests/*.sh
```

### 2. Common Issues

#### Unquoted Variables

```bash
# Bad
echo $message

# Good
echo "$message"
```

#### Missing Local

```bash
# Bad
my_func() {
    result="value"
}

# Good
my_func() {
    local result="value"
}
```

#### Command Check

```bash
# Bad
if which jq; then

# Good
if command -v jq &> /dev/null; then
```

## Success Criteria

- shellcheck returns exit code 0
- No warnings or errors
