#!/bin/bash

# Claude Code session parser for who-ran-what
# Parses ~/.claude/projects/ for agent and skill usage

CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# Parse all Claude Code sessions and extract tool usage
parse_claude_sessions() {
    local start_date="${1:-}"
    local end_date="${2:-}"
    local project_filter="${3:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        echo "[]"
        return
    fi

    local results="[]"

    # Find all JSONL session files
    while IFS= read -r -d '' session_file; do
        local project_path=$(dirname "$session_file")
        local project_name=$(basename "$project_path" | sed 's/^-//' | tr '-' '/')

        # Skip if project filter doesn't match
        if [[ -n "$project_filter" ]] && [[ "$project_name" != *"$project_filter"* ]]; then
            continue
        fi

        # Parse the session file
        parse_session_file "$session_file" "$project_name" "$start_date" "$end_date"

    done < <(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -print0 2>/dev/null)
}

# Parse a single session file
parse_session_file() {
    local file="$1"
    local project="$2"
    local start_date="$3"
    local end_date="$4"

    # Use jq if available, otherwise fall back to grep
    if command -v jq &> /dev/null; then
        parse_with_jq "$file" "$project" "$start_date" "$end_date"
    else
        parse_with_grep "$file" "$project" "$start_date" "$end_date"
    fi
}

# Parse using jq (more accurate)
parse_with_jq() {
    local file="$1"
    local project="$2"
    local start_date="$3"
    local end_date="$4"

    jq -r --arg project "$project" --arg start "$start_date" --arg end "$end_date" '
        select(.message.content != null) |
        select(.message.role == "assistant") |
        .timestamp as $ts |
        .message.content[] |
        select(.type == "tool_use") |
        {
            timestamp: $ts,
            project: $project,
            tool: .name,
            input: .input
        }
    ' "$file" 2>/dev/null
}

# Parse using grep (fallback)
parse_with_grep() {
    local file="$1"
    local project="$2"
    local start_date="$3"
    local end_date="$4"

    # Extract tool_use entries
    grep -o '"type":"tool_use"[^}]*}' "$file" 2>/dev/null | while read -r line; do
        local tool=$(echo "$line" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        echo "$project|$tool"
    done
}

# Count agent (Task) usage by subagent_type
count_agents() {
    local start_date="${1:-}"
    local end_date="${2:-}"
    local project_filter="${3:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find Task tool calls and extract subagent_type
    find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -print0 2>/dev/null | \
    xargs -0 grep -h '"name":"Task"' 2>/dev/null | \
    grep -o '"subagent_type":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count skill usage
count_skills() {
    local start_date="${1:-}"
    local end_date="${2:-}"
    local project_filter="${3:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find Skill tool calls and extract skill name
    find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -print0 2>/dev/null | \
    xargs -0 grep -h '"name":"Skill"' 2>/dev/null | \
    grep -o '"skill":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count general tool usage
count_tools() {
    local start_date="${1:-}"
    local end_date="${2:-}"
    local project_filter="${3:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find all tool_use entries and extract tool names
    find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -print0 2>/dev/null | \
    xargs -0 grep -h '"type":"tool_use"' 2>/dev/null | \
    grep -o '"name":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Get usage for a specific project
count_project_usage() {
    local project_path="$1"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Convert project path to Claude's format
    local claude_project_dir=$(echo "$project_path" | sed 's|/|-|g; s|^-||')
    local full_path="$CLAUDE_PROJECTS_DIR/-$claude_project_dir"

    if [[ ! -d "$full_path" ]]; then
        echo "No Claude data found for this project"
        return
    fi

    echo "=== Agents ==="
    grep -h '"name":"Task"' "$full_path"/*.jsonl 2>/dev/null | \
    grep -o '"subagent_type":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn

    echo ""
    echo "=== Skills ==="
    grep -h '"name":"Skill"' "$full_path"/*.jsonl 2>/dev/null | \
    grep -o '"skill":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn

    echo ""
    echo "=== Tools ==="
    grep -oh '"name":"[A-Z][^"]*"' "$full_path"/*.jsonl 2>/dev/null | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn | head -10
}

# Get all projects with Claude data
list_projects() {
    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    find "$CLAUDE_PROJECTS_DIR" -maxdepth 1 -type d -name "-*" | while read -r dir; do
        local name=$(basename "$dir" | sed 's/^-//' | tr '-' '/')
        local count=$(find "$dir" -name "*.jsonl" | wc -l | tr -d ' ')
        echo "$count sessions: $name"
    done | sort -rn
}
