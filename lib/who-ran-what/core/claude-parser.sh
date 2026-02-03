#!/bin/bash

# Claude Code session parser for who-ran-what
# Parses ~/.claude/projects/ for agent and skill usage

CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# Get date for filtering (returns YYYY-MM-DD format)
get_filter_date() {
    local period="$1"
    local os_type
    os_type=$(uname -s)

    case "$period" in
        "today")
            date +%Y-%m-%d
            ;;
        "week")
            if [[ "$os_type" == "Darwin" ]]; then
                date -v-7d +%Y-%m-%d
            else
                date -d "7 days ago" +%Y-%m-%d
            fi
            ;;
        "month")
            if [[ "$os_type" == "Darwin" ]]; then
                date -v-30d +%Y-%m-%d
            else
                date -d "30 days ago" +%Y-%m-%d
            fi
            ;;
        *)
            # Return empty for "all" or invalid period
            echo ""
            ;;
    esac
}

# Find session files with date filter
find_session_files() {
    local period="${1:-all}"
    local filter_date

    filter_date=$(get_filter_date "$period")

    if [[ -z "$filter_date" ]]; then
        # No date filter - return all files
        find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -print0 2>/dev/null
    else
        # Filter by modification time
        find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -newermt "$filter_date" -print0 2>/dev/null
    fi
}

# Parse all Claude Code sessions and extract tool usage
parse_claude_sessions() {
    local start_date="${1:-}"
    local end_date="${2:-}"
    local project_filter="${3:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        echo "[]"
        return
    fi

    # Find all JSONL session files
    while IFS= read -r -d '' session_file; do
        local project_path
        local project_name
        project_path=$(dirname "$session_file")
        project_name=$(basename "$project_path" | sed 's/^-//' | tr '-' '/')

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
        local tool
        tool=$(echo "$line" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        echo "$project|$tool"
    done
}

# Count agent (Task) usage by subagent_type
count_agents() {
    local period="${1:-all}"
    local project_filter="${2:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find Task tool calls and extract subagent_type
    find_session_files "$period" | \
    xargs -0 grep -h '"name":"Task"' 2>/dev/null | \
    grep -o '"subagent_type":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count skill usage
count_skills() {
    local period="${1:-all}"
    local project_filter="${2:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find Skill tool calls and extract skill name
    find_session_files "$period" | \
    xargs -0 grep -h '"name":"Skill"' 2>/dev/null | \
    grep -o '"skill":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count general tool usage
count_tools() {
    local period="${1:-all}"
    local project_filter="${2:-}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Find all tool_use entries and extract tool names
    find_session_files "$period" | \
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
    local claude_project_dir
    claude_project_dir=$(echo "$project_path" | sed 's|/|-|g; s|^-||')
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
    local period="${1:-all}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    find "$CLAUDE_PROJECTS_DIR" -maxdepth 1 -type d -name "-*" | while read -r dir; do
        local name
        local count
        name=$(basename "$dir" | sed 's/^-//' | tr '-' '/')

        if [[ "$period" == "all" ]]; then
            count=$(find "$dir" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')
        else
            local filter_date
            filter_date=$(get_filter_date "$period")
            if [[ -n "$filter_date" ]]; then
                count=$(find "$dir" -name "*.jsonl" -newermt "$filter_date" 2>/dev/null | wc -l | tr -d ' ')
            else
                count=$(find "$dir" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')
            fi
        fi

        if [[ "$count" -gt 0 ]]; then
            echo "$count sessions: $name"
        fi
    done | sort -rn
}

# Find unused agents (not used in the specified period)
find_unused_agents() {
    local period="${1:-month}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Get all available agent types from Claude's system
    local all_agents="Explore Plan general-purpose code-reviewer test-engineer quality-engineer security-auditor backend-architect git-specialist full-stack-architect frontend-developer api-documenter devops-engineer database-optimizer cloud-architect deployment-engineer"

    # Get recently used agents
    local used_agents
    used_agents=$(count_agents "$period" | awk '{print $2}' | tr '\n' ' ')

    # Find agents that are available but not used
    for agent in $all_agents; do
        if [[ ! " $used_agents " =~ [[:space:]]${agent}[[:space:]] ]]; then
            echo "$agent"
        fi
    done
}

# Find unused skills (not used in the specified period)
find_unused_skills() {
    local period="${1:-month}"
    local project_root="${2:-$(pwd)}"

    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        return
    fi

    # Get configured skills from project's .claude/commands
    local configured_skills=""
    if [[ -d "$project_root/.claude/commands" ]]; then
        configured_skills=$(find "$project_root/.claude/commands" -name "*.md" -exec basename {} .md \; 2>/dev/null | tr '\n' ' ')
    fi

    # Get recently used skills
    local used_skills
    used_skills=$(count_skills "$period" | awk '{print $2}' | tr '\n' ' ')

    # Find skills that are configured but not used
    for skill in $configured_skills; do
        if [[ ! " $used_skills " =~ [[:space:]]${skill}[[:space:]] ]]; then
            echo "$skill"
        fi
    done
}

# Get usage summary with period comparison
get_usage_summary() {
    local period="${1:-week}"

    echo "=== Usage Summary ($period) ==="
    echo ""

    local agent_count
    local skill_count
    local tool_count

    agent_count=$(count_agents "$period" | wc -l | tr -d ' ')
    skill_count=$(count_skills "$period" | wc -l | tr -d ' ')
    tool_count=$(count_tools "$period" | wc -l | tr -d ' ')

    echo "Unique agents used: $agent_count"
    echo "Unique skills used: $skill_count"
    echo "Unique tools used: $tool_count"
}
