---
description: Validate all shell scripts with shellcheck
---

# Validate Scripts

Execute these steps NOW:

## Step 1: Run shellcheck on all scripts

```bash
shellcheck -x -e SC1091 bin/who-ran-what
shellcheck -x -e SC1091 lib/who-ran-what/**/*.sh
shellcheck -x -e SC1091 tests/*.sh
```

## Step 2: Run syntax check

```bash
bash -n bin/who-ran-what
```

## Step 3: Run tests

```bash
./tests/run_all.sh
```

## Step 4: Report results

Tell the user:
- ✅ How many files passed
- ❌ Any errors found (with line numbers)
- 💡 Suggested fixes for any issues
