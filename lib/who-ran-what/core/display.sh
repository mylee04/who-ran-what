#!/bin/bash

# Display utilities for who-ran-what

# Draw a progress bar
draw_bar() {
    local value="$1"
    local max="$2"
    local width="${3:-20}"

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

# Display agent stats
show_agent_stats() {
    local period="${1:-week}"

    header "📊 Top Agents (This $period)"

    # TODO: Replace with actual data
    echo -e "  ├── Sisyphus      $(draw_bar 847 1000)  ${CYAN}847 calls${RESET}"
    echo -e "  ├── Oracle        $(draw_bar 412 1000)  ${CYAN}412 calls${RESET}"
    echo -e "  ├── Librarian     $(draw_bar 298 1000)  ${CYAN}298 calls${RESET}"
    echo -e "  └── Explore       $(draw_bar 201 1000)  ${CYAN}201 calls${RESET}"
}

# Display skill stats
show_skill_stats() {
    local period="${1:-week}"

    header "🔧 Top Skills"

    # TODO: Replace with actual data
    echo -e "  ├── git-master    $(draw_bar 523 600)  ${CYAN}523 uses${RESET}"
    echo -e "  ├── playwright    $(draw_bar 287 600)  ${CYAN}287 uses${RESET}"
    echo -e "  └── web-search    $(draw_bar 178 600)  ${CYAN}178 uses${RESET}"
}

# Display unused items
show_unused() {
    header "⚠️  Unused (30+ days)"

    # TODO: Replace with actual data
    echo -e "  └── ${DIM}deprecated-skill, old-mcp${RESET}     → ${YELLOW}Remove?${RESET}"
}

# Display project breakdown
show_project_breakdown() {
    header "📁 By Project"

    # TODO: Replace with actual data
    echo -e "  ├── ${CYAN}code-notify/${RESET}  - Sisyphus 90%, Oracle 10%"
    echo -e "  └── ${CYAN}my-app/${RESET}       - Frontend 60%, Librarian 40%"
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
    show_unused
    echo ""
    show_project_breakdown
    echo ""
}
