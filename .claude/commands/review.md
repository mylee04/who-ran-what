---
description: Review changed shell scripts for quality and security
---

# Code Review

Execute these steps NOW:

## Step 1: Identify changed files

```bash
git diff --name-only HEAD~1 | grep -E '\.(sh|bash)$' || git diff --name-only HEAD~1
```

## Step 2: For each changed file, check:

### Security (BLOCK if found)
- [ ] No hardcoded credentials or API keys
- [ ] No `eval` on user input
- [ ] No command injection vulnerabilities

### Shell Best Practices (NEEDS CHANGES if found)
- [ ] All variables quoted: `"$var"`
- [ ] Functions use `local` for variables
- [ ] Uses `[[ ]]` not `[ ]`
- [ ] Uses `command -v` not `which`

### Code Quality
- [ ] Functions are small and focused
- [ ] Variable names are clear
- [ ] No dead code

## Step 3: Output format

```markdown
## Code Review: [filename]

### Security: ✅ PASS / ❌ ISSUES
[list any issues]

### Best Practices: ✅ PASS / ⚠️ WARNINGS
[list any issues with line numbers]

### Verdict: APPROVE / NEEDS CHANGES / BLOCK
```

## Step 4: Run shellcheck

```bash
shellcheck -x -e SC1091 [changed files]
```
