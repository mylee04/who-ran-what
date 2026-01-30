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

# Format period for display
format_period() {
    local period="$1"
    case "$period" in
        "today") echo "Today" ;;
        "week") echo "This Week" ;;
        "month") echo "This Month" ;;
        "all") echo "All Time" ;;
        *) echo "$period" ;;
    esac
}

# Display agent stats (real data)
show_agent_stats() {
    local period="${1:-week}"
    local display_period
    display_period=$(format_period "$period")

    header "📊 Top Agents ($display_period)"

    # Get real agent data with period filter
    local agent_data
    agent_data=$(count_agents "$period" 2>/dev/null)

    if [[ -z "$agent_data" ]]; then
        echo -e "  ${DIM}No agent data found${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$agent_data" | head -1 | awk '{print $1}')

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

    # Get real skill data with period filter
    local skill_data
    skill_data=$(count_skills "$period" 2>/dev/null)

    if [[ -z "$skill_data" ]]; then
        echo -e "  ${DIM}No skill data found${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$skill_data" | head -1 | awk '{print $1}')

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

    # Get real tool data with period filter
    local tool_data
    tool_data=$(count_tools "$period" 2>/dev/null)

    if [[ -z "$tool_data" ]]; then
        echo -e "  ${DIM}No tool data found${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$tool_data" | head -1 | awk '{print $1}')

    echo "$tool_data" | head -8 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d uses${RESET}\n" "$name" "$count"
        fi
    done
}

# Display unused items
show_unused() {
    local period="${1:-month}"
    local display_period
    display_period=$(format_period "$period")

    header "⚠️  Unused ($display_period)"

    # Get unused agents
    local unused_agents
    unused_agents=$(find_unused_agents "$period" 2>/dev/null)

    if [[ -n "$unused_agents" ]]; then
        echo -e "  ${YELLOW}Unused Agents:${RESET}"
        echo "$unused_agents" | head -5 | while read -r agent; do
            if [[ -n "$agent" ]]; then
                echo -e "    └── ${DIM}$agent${RESET}"
            fi
        done
    fi

    # Get unused skills
    local unused_skills
    unused_skills=$(find_unused_skills "$period" 2>/dev/null)

    if [[ -n "$unused_skills" ]]; then
        echo ""
        echo -e "  ${YELLOW}Unused Skills:${RESET}"
        echo "$unused_skills" | head -5 | while read -r skill; do
            if [[ -n "$skill" ]]; then
                echo -e "    └── ${DIM}$skill${RESET}"
            fi
        done
    fi

    if [[ -z "$unused_agents" ]] && [[ -z "$unused_skills" ]]; then
        echo -e "  ${GREEN}All agents and skills are being used!${RESET}"
    fi
}

# Display project breakdown
show_project_breakdown() {
    local period="${1:-week}"

    header "📁 Projects with Claude Data"

    local projects
    projects=$(list_projects "$period" 2>/dev/null | head -5)

    if [[ -z "$projects" ]]; then
        echo -e "  ${DIM}No project data found${RESET}"
        return
    fi

    echo "$projects" | while read -r line; do
        local sessions
        local path
        local name
        sessions=$(echo "$line" | cut -d' ' -f1)
        path=$(echo "$line" | cut -d' ' -f3-)
        name=$(basename "$path")
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
    show_project_breakdown "$period"
    echo ""
}
