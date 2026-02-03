---
description: Run tests for who-ran-what CLI
---

# Run Tests

## What This Command Does

1. Runs all test scripts in the tests/ directory
2. Validates command output
3. Reports pass/fail status

## Process

### 1. Check Test Directory

```bash
# Verify tests directory exists
if [[ ! -d "tests" ]]; then
    echo "No tests directory found"
    exit 0
fi
```

### 2. Run Tests

```bash
# Run each test file
for test_file in tests/*.sh; do
    echo "Running: $test_file"
    bash "$test_file"
done
```

### 3. Quick Smoke Tests

If no test directory exists, run these basic checks:

```bash
# Test help command
./bin/who-ran-what help

# Test version command
./bin/who-ran-what version

# Test default dashboard
./bin/who-ran-what

# Test each subcommand
./bin/who-ran-what today
./bin/who-ran-what week
./bin/who-ran-what month
./bin/who-ran-what agents
./bin/who-ran-what projects
```

## Success Criteria

- All commands exit with code 0
- No error messages in stderr
- Output is readable and formatted correctly
