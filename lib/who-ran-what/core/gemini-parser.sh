#!/bin/bash

# Gemini CLI session parser for who-ran-what
# Parses ~/.gemini/telemetry.log for tool usage
#
# Requires Gemini CLI telemetry to be enabled:
# Add to ~/.gemini/settings.json:
# {
#   "telemetry": {
#     "enabled": true,
#     "target": "local",
#     "outfile": "~/.gemini/telemetry.log"
#   }
# }

GEMINI_TELEMETRY_FILE="$HOME/.gemini/telemetry.log"

# Check if Gemini telemetry is available
has_gemini_telemetry() {
    [[ -f "$GEMINI_TELEMETRY_FILE" ]] && [[ -s "$GEMINI_TELEMETRY_FILE" ]]
}

# Find telemetry entries with date filter
find_gemini_entries() {
    local period="${1:-all}"

    if [[ ! -f "$GEMINI_TELEMETRY_FILE" ]]; then
        return
    fi

    local filter_date
    filter_date=$(get_filter_date "$period")

    if [[ -z "$filter_date" ]]; then
        cat "$GEMINI_TELEMETRY_FILE"
    else
        # Filter by timestamp in the log entries
        while IFS= read -r line; do
            local entry_date
            entry_date=$(echo "$line" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4 | cut -d'T' -f1 2>/dev/null)
            if [[ -n "$entry_date" ]] && [[ ! "$entry_date" < "$filter_date" ]]; then
                echo "$line"
            fi
        done < "$GEMINI_TELEMETRY_FILE"
    fi
}

# Count Gemini tool usage
count_gemini_tools() {
    local period="${1:-all}"

    if ! has_gemini_telemetry; then
        return
    fi

    # Extract tool_call events and count tool names
    find_gemini_entries "$period" | \
    grep '"event":"tool_call"' | \
    grep -o '"tool_name":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count total Gemini calls for trend comparison
count_gemini_total_calls() {
    local period="${1:-week}"

    if ! has_gemini_telemetry; then
        echo "0"
        return
    fi

    local count
    count=$(find_gemini_entries "$period" | grep -c '"event":"tool_call"' 2>/dev/null || echo "0")
    echo "$count"
}

# Get Gemini trend data
get_gemini_trend_data() {
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

    current_count=$(count_gemini_total_calls "$period")
    previous_count=$(count_gemini_total_calls "$previous_period")

    local change=0
    if [[ "$previous_count" -gt 0 ]]; then
        change=$(( (current_count - previous_count) * 100 / previous_count ))
    fi

    echo "$current_count|$previous_count|$change"
}

# List Gemini sessions (unique session IDs)
list_gemini_sessions() {
    local period="${1:-all}"

    if ! has_gemini_telemetry; then
        return
    fi

    find_gemini_entries "$period" | \
    grep -o '"session_id":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort -u | wc -l | tr -d ' '
}

# Get Gemini usage summary
get_gemini_summary() {
    local period="${1:-week}"

    if ! has_gemini_telemetry; then
        echo "Gemini telemetry not enabled"
        return
    fi

    local tool_count
    local session_count
    local total_calls

    tool_count=$(count_gemini_tools "$period" | wc -l | tr -d ' ')
    session_count=$(list_gemini_sessions "$period")
    total_calls=$(count_gemini_total_calls "$period")

    echo "Sessions: $session_count"
    echo "Tool calls: $total_calls"
    echo "Unique tools: $tool_count"
}
