#!/bin/bash

# JSON output utilities for who-ran-what
# shellcheck disable=SC2034  # Variables used by sourcing scripts

# Global flag for JSON output
JSON_OUTPUT="${JSON_OUTPUT:-false}"

# Escape special characters for JSON string
json_escape() {
    local str="$1"
    # Escape backslashes first, then quotes, then control characters
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

# Output JSON array from count data (format: "count name")
count_to_json_array() {
    local data="$1"
    local key_name="${2:-name}"
    local value_name="${3:-count}"

    if [[ -z "$data" ]]; then
        echo "[]"
        return
    fi

    local first=true
    echo -n "["

    while read -r count name; do
        if [[ -n "$name" ]]; then
            local escaped_name
            escaped_name=$(json_escape "$name")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "{\"$key_name\":\"$escaped_name\",\"$value_name\":$count}"
        fi
    done <<< "$data"

    echo "]"
}

# Output JSON array from simple list
list_to_json_array() {
    local data="$1"

    if [[ -z "$data" ]]; then
        echo "[]"
        return
    fi

    local first=true
    echo -n "["

    while read -r item; do
        if [[ -n "$item" ]]; then
            local escaped_item
            escaped_item=$(json_escape "$item")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "\"$escaped_item\""
        fi
    done <<< "$data"

    echo "]"
}

# Output projects as JSON
projects_to_json_array() {
    local data="$1"

    if [[ -z "$data" ]]; then
        echo "[]"
        return
    fi

    local first=true
    echo -n "["

    while read -r line; do
        local sessions
        local path
        local name
        sessions=$(echo "$line" | cut -d' ' -f1)
        path=$(echo "$line" | cut -d' ' -f3-)
        name=$(basename "$path")

        if [[ -n "$name" ]]; then
            local escaped_name escaped_path
            escaped_name=$(json_escape "$name")
            escaped_path=$(json_escape "$path")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "{\"name\":\"$escaped_name\",\"path\":\"$escaped_path\",\"sessions\":$sessions}"
        fi
    done <<< "$data"

    echo "]"
}

# Generate trend JSON object
generate_trend_json_object() {
    local period="${1:-week}"

    # Only week and month have trend data
    if [[ "$period" != "week" ]] && [[ "$period" != "month" ]]; then
        echo '{"current":0,"previous":0,"change":0}'
        return
    fi

    local trend_data
    trend_data=$(get_trend_data "$period")

    local current
    local previous
    local change
    current=$(echo "$trend_data" | cut -d'|' -f1)
    previous=$(echo "$trend_data" | cut -d'|' -f2)
    change=$(echo "$trend_data" | cut -d'|' -f3)

    echo "{\"current\":$current,\"previous\":$previous,\"change\":$change}"
}

# Generate full dashboard JSON
generate_dashboard_json() {
    local period="${1:-week}"

    local agents
    local skills
    local tools
    local projects
    local unused_agents
    local unused_skills

    agents=$(count_agents "$period" 2>/dev/null)
    skills=$(count_skills "$period" 2>/dev/null)
    tools=$(count_tools "$period" 2>/dev/null)
    projects=$(list_projects "$period" 2>/dev/null)
    unused_agents=$(find_unused_agents "$period" 2>/dev/null)
    unused_skills=$(find_unused_skills "$period" 2>/dev/null)

    cat << EOF
{
  "version": "$VERSION",
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents": $(count_to_json_array "$agents" "name" "calls"),
  "skills": $(count_to_json_array "$skills" "name" "uses"),
  "tools": $(count_to_json_array "$tools" "name" "uses"),
  "projects": $(projects_to_json_array "$projects"),
  "unused": {
    "agents": $(list_to_json_array "$unused_agents"),
    "skills": $(list_to_json_array "$unused_skills")
  },
  "trend": $(generate_trend_json_object "$period")
}
EOF
}

# Generate agents-only JSON
generate_agents_json() {
    local period="${1:-all}"
    local agents
    agents=$(count_agents "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents": $(count_to_json_array "$agents" "name" "calls")
}
EOF
}

# Generate skills-only JSON
generate_skills_json() {
    local period="${1:-all}"
    local skills
    skills=$(count_skills "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "skills": $(count_to_json_array "$skills" "name" "uses")
}
EOF
}

# Generate tools-only JSON
generate_tools_json() {
    local period="${1:-all}"
    local tools
    tools=$(count_tools "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tools": $(count_to_json_array "$tools" "name" "uses")
}
EOF
}

# Generate projects-only JSON
generate_projects_json() {
    local period="${1:-all}"
    local projects
    projects=$(list_projects "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "projects": $(projects_to_json_array "$projects")
}
EOF
}

# Generate unused-only JSON
generate_unused_json() {
    local period="${1:-month}"
    local unused_agents
    local unused_skills
    unused_agents=$(find_unused_agents "$period" 2>/dev/null)
    unused_skills=$(find_unused_skills "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "unused": {
    "agents": $(list_to_json_array "$unused_agents"),
    "skills": $(list_to_json_array "$unused_skills")
  }
}
EOF
}

# Generate Gemini-only JSON
generate_gemini_json() {
    local period="${1:-week}"

    if ! has_gemini_telemetry; then
        cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "enabled": false,
  "tools": [],
  "sessions": 0,
  "total_calls": 0
}
EOF
        return
    fi

    local tools
    local session_count
    local total_calls
    tools=$(count_gemini_tools "$period" 2>/dev/null)
    session_count=$(list_gemini_sessions "$period" 2>/dev/null)
    total_calls=$(count_gemini_total_calls "$period" 2>/dev/null)

    cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "enabled": true,
  "tools": $(count_to_json_array "$tools" "name" "calls"),
  "sessions": $session_count,
  "total_calls": $total_calls
}
EOF
}
