---
description: Show detailed usage statistics and analytics
---

# Usage Statistics

## What This Command Does

Provides in-depth analysis of Claude Code usage patterns.

## Analysis Areas

### 1. Tool Usage Breakdown

```bash
# Show all tools used, sorted by frequency
./bin/who-ran-what month | grep -A 20 "Top Tools"
```

### 2. Agent Efficiency

Compare agent usage patterns:
- Which agents are used most?
- Are any agents underutilized?
- Usage trends over time

### 3. Project Activity

```bash
# List all projects with Claude data
./bin/who-ran-what projects

# Check specific project
./bin/who-ran-what project
```

### 4. Time-Based Analysis

```bash
# Daily activity
./bin/who-ran-what today

# Weekly trends
./bin/who-ran-what week

# Monthly overview
./bin/who-ran-what month
```

### 5. Cleanup Recommendations

```bash
# Find unused agents and skills
./bin/who-ran-what clean
```

## Insights to Look For

1. **High Bash usage** - Might benefit from more specialized tools
2. **Low agent usage** - Could leverage agents more for complex tasks
3. **Unused skills** - Consider removing or using configured skills
4. **Project patterns** - Identify most active projects

## Custom Analysis

For deeper analysis, the raw session data is in:
```
~/.claude/projects/*/sessions/*.jsonl
```

Use jq to extract specific patterns:
```bash
# Count tool calls by type
jq -r 'select(.message.content) | .message.content[] | select(.type=="tool_use") | .name' \
    ~/.claude/projects/*/sessions/*.jsonl | sort | uniq -c | sort -rn
```
