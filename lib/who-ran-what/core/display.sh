#!/bin/bash

# Display utilities for who-ran-what

# Draw a progress bar
draw_bar() {
    local value="$1"
    local max="$2"
    local width="${3:-20}"

    if [[ "$max" -eq 0 ]]; then
        max=1
    fi

    local filled=$((value * width / max))
    local empty=$((width - filled))

    printf "%s" "${GREEN}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "%s" "${DIM}"
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "%s" "${RESET}"
}

# Display dashboard header
show_dashboard_header() {
    local period="${1:-week}"

    echo ""
    echo -e "${BOLD}who-ran-what${RESET}                    ${DIM}$period${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Display agent stats (real data)
show_agent_stats() {
    local period="${1:-week}"

    header "📊 Top Agents (This $period)"

    # Get real agent data
    local agent_data=$(count_agents 2>/dev/null)

    if [[ -z "$agent_data" ]]; then
        echo -e "  ${DIM}No agent data found${RESET}"
        return
    fi

    local max_count=$(echo "$agent_data" | head -1 | awk '{print $1}')

    echo "$agent_data" | head -5 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d calls${RESET}\n" "$name" "$count"
        fi
    done
}

# Display skill stats (real data)
show_skill_stats() {
    local period="${1:-week}"

    header "🔧 Top Skills"

    # Get real skill data
    local skill_data=$(count_skills 2>/dev/null)

    if [[ -z "$skill_data" ]]; then
        echo -e "  ${DIM}No skill data found${RESET}"
        return
    fi

    local max_count=$(echo "$skill_data" | head -1 | awk '{print $1}')

    echo "$skill_data" | head -5 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d uses${RESET}\n" "$name" "$count"
        fi
    done
}

# Display tool stats (real data)
show_tool_stats() {
    local period="${1:-week}"

    header "🛠️  Top Tools"

    # Get real tool data
    local tool_data=$(count_tools 2>/dev/null)

    if [[ -z "$tool_data" ]]; then
        echo -e "  ${DIM}No tool data found${RESET}"
        return
    fi

    local max_count=$(echo "$tool_data" | head -1 | awk '{print $1}')

    echo "$tool_data" | head -8 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d uses${RESET}\n" "$name" "$count"
        fi
    done
}

# Display unused items
show_unused() {
    header "⚠️  Unused (30+ days)"

    # TODO: Implement actual unused detection
    echo -e "  ${DIM}Analysis not yet implemented${RESET}"
}

# Display project breakdown
show_project_breakdown() {
    header "📁 Projects with Claude Data"

    local projects=$(list_projects 2>/dev/null | head -5)

    if [[ -z "$projects" ]]; then
        echo -e "  ${DIM}No project data found${RESET}"
        return
    fi

    echo "$projects" | while read -r line; do
        local sessions=$(echo "$line" | cut -d' ' -f1)
        local path=$(echo "$line" | cut -d' ' -f3-)
        local name=$(basename "$path")
        printf "  ├── ${CYAN}%-20s${RESET} %s sessions\n" "$name" "$sessions"
    done
}

# Main dashboard display
show_dashboard() {
    local period="${1:-week}"

    show_dashboard_header "$period"
    echo ""
    show_agent_stats "$period"
    echo ""
    show_skill_stats "$period"
    echo ""
    show_tool_stats "$period"
    echo ""
    show_project_breakdown
    echo ""
}
