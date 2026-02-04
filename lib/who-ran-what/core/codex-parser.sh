#!/bin/bash

# Codex CLI session parser for who-ran-what
# Parses ~/.codex/sessions/ for tool usage
# https://developers.openai.com/codex/cli/

CODEX_SESSIONS_DIR="$HOME/.codex/sessions"

# Check if Codex session data is available
has_codex_sessions() {
    [[ -d "$CODEX_SESSIONS_DIR" ]] && [[ -n "$(find "$CODEX_SESSIONS_DIR" -name "*.jsonl" 2>/dev/null | head -1)" ]]
}

# Find Codex session files with date filter
find_codex_session_files() {
    local period="${1:-all}"

    if [[ ! -d "$CODEX_SESSIONS_DIR" ]]; then
        return
    fi

    local filter_date
    filter_date=$(get_filter_date "$period")

    if [[ -z "$filter_date" ]]; then
        find "$CODEX_SESSIONS_DIR" -name "*.jsonl" -print0 2>/dev/null
    else
        find "$CODEX_SESSIONS_DIR" -name "*.jsonl" -newermt "$filter_date" -print0 2>/dev/null
    fi
}

# Count Codex tool usage
count_codex_tools() {
    local period="${1:-all}"

    if ! has_codex_sessions; then
        return
    fi

    # Extract tool_use/function_call entries and count tool names
    # Codex uses "function_call" or "tool_calls" format
    find_codex_session_files "$period" | \
    xargs -0 grep -h -E '"(type":"tool_use|function_call|tool_calls)' 2>/dev/null | \
    grep -o '"name":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count total Codex tool calls for trend comparison
count_codex_total_calls() {
    local period="${1:-week}"

    if ! has_codex_sessions; then
        echo "0"
        return
    fi

    local count
    count=$(find_codex_session_files "$period" | xargs -0 grep -h -c -E '"(type":"tool_use|function_call|tool_calls)' 2>/dev/null | awk '{s+=$1} END {print s+0}')
    echo "$count"
}

# Get Codex trend data
get_codex_trend_data() {
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

    current_count=$(count_codex_total_calls "$period")
    previous_count=$(count_codex_total_calls "$previous_period")

    local change=0
    if [[ "$previous_count" -gt 0 ]]; then
        change=$(( (current_count - previous_count) * 100 / previous_count ))
    fi

    echo "$current_count|$previous_count|$change"
}

# List Codex sessions count
list_codex_sessions() {
    local period="${1:-all}"

    if ! has_codex_sessions; then
        echo "0"
        return
    fi

    local count
    if [[ "$period" == "all" ]]; then
        count=$(find "$CODEX_SESSIONS_DIR" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')
    else
        local filter_date
        filter_date=$(get_filter_date "$period")
        if [[ -n "$filter_date" ]]; then
            count=$(find "$CODEX_SESSIONS_DIR" -name "*.jsonl" -newermt "$filter_date" 2>/dev/null | wc -l | tr -d ' ')
        else
            count=$(find "$CODEX_SESSIONS_DIR" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')
        fi
    fi
    echo "$count"
}

# Get Codex usage summary
get_codex_summary() {
    local period="${1:-week}"

    if ! has_codex_sessions; then
        echo "No Codex CLI session data found"
        return
    fi

    local tool_count
    local session_count
    local total_calls

    tool_count=$(count_codex_tools "$period" | wc -l | tr -d ' ')
    session_count=$(list_codex_sessions "$period")
    total_calls=$(count_codex_total_calls "$period")

    echo "Sessions: $session_count"
    echo "Tool calls: $total_calls"
    echo "Unique tools: $tool_count"
}
