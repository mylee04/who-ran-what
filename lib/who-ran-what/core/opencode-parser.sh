#!/bin/bash

# OpenCode session parser for who-ran-what
# Parses ~/.local/share/opencode/storage/ for tool usage
# https://opencode.ai/

OPENCODE_STORAGE_DIR="$HOME/.local/share/opencode/storage"
OPENCODE_PART_DIR="$OPENCODE_STORAGE_DIR/part"
OPENCODE_SESSION_DIR="$OPENCODE_STORAGE_DIR/session"

# Check if OpenCode data is available
has_opencode_sessions() {
    [[ -d "$OPENCODE_PART_DIR" ]] && [[ -n "$(find "$OPENCODE_PART_DIR" -name "*.json" 2>/dev/null | head -1)" ]]
}

# Find OpenCode part files with date filter
find_opencode_part_files() {
    local period="${1:-all}"

    if [[ ! -d "$OPENCODE_PART_DIR" ]]; then
        return
    fi

    local filter_date
    filter_date=$(get_filter_date "$period")

    if [[ -z "$filter_date" ]]; then
        find "$OPENCODE_PART_DIR" -name "*.json" -print0 2>/dev/null
    else
        find "$OPENCODE_PART_DIR" -name "*.json" -newermt "$filter_date" -print0 2>/dev/null
    fi
}

# Count OpenCode tool usage
count_opencode_tools() {
    local period="${1:-all}"

    if ! has_opencode_sessions; then
        return
    fi

    # Extract tool names from part files with type "tool"
    find_opencode_part_files "$period" | \
    xargs -0 grep -l '"type": *"tool"' 2>/dev/null | \
    xargs grep -h '"tool":' 2>/dev/null | \
    grep -o '"tool": *"[^"]*"' | \
    sed 's/"tool": *"//' | sed 's/"$//' | \
    sort | uniq -c | sort -rn
}

# Count total OpenCode tool calls for trend comparison
count_opencode_total_calls() {
    local period="${1:-week}"

    if ! has_opencode_sessions; then
        echo "0"
        return
    fi

    local count
    count=$(find_opencode_part_files "$period" | xargs -0 grep -l '"type": *"tool"' 2>/dev/null | wc -l | tr -d ' ')
    echo "$count"
}

# Get OpenCode trend data
get_opencode_trend_data() {
    local period="${1:-week}"
    local current_count
    local previous_count
    local previous_period

    case "$period" in
        "week")
            previous_period="last_week"
            ;;
        "month")
            previous_period="last_month"
            ;;
        *)
            echo "0|0|0"
            return
            ;;
    esac

    current_count=$(count_opencode_total_calls "$period")
    previous_count=$(count_opencode_total_calls "$previous_period")

    local change=0
    if [[ "$previous_count" -gt 0 ]]; then
        change=$(( (current_count - previous_count) * 100 / previous_count ))
    fi

    echo "$current_count|$previous_count|$change"
}

# List OpenCode sessions count
list_opencode_sessions() {
    local period="${1:-all}"

    if [[ ! -d "$OPENCODE_SESSION_DIR" ]]; then
        echo "0"
        return
    fi

    local count
    if [[ "$period" == "all" ]]; then
        count=$(find "$OPENCODE_SESSION_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    else
        local filter_date
        filter_date=$(get_filter_date "$period")
        if [[ -n "$filter_date" ]]; then
            count=$(find "$OPENCODE_SESSION_DIR" -name "*.json" -newermt "$filter_date" 2>/dev/null | wc -l | tr -d ' ')
        else
            count=$(find "$OPENCODE_SESSION_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
        fi
    fi
    echo "$count"
}

# Get OpenCode usage summary
get_opencode_summary() {
    local period="${1:-week}"

    if ! has_opencode_sessions; then
        echo "No OpenCode session data found"
        return
    fi

    local tool_count
    local session_count
    local total_calls

    tool_count=$(count_opencode_tools "$period" | wc -l | tr -d ' ')
    session_count=$(list_opencode_sessions "$period")
    total_calls=$(count_opencode_total_calls "$period")

    echo "Sessions: $session_count"
    echo "Tool calls: $total_calls"
    echo "Unique tools: $tool_count"
}
