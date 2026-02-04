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

# Generic stats display function (reduces duplication)
# Usage: show_stats_section "title" "data" "unit" [limit]
show_stats_section() {
    local title="$1"
    local data="$2"
    local unit="$3"
    local limit="${4:-5}"
    local empty_msg="${5:-No data found}"

    header "$title"

    if [[ -z "$data" ]]; then
        echo -e "  ${DIM}${empty_msg}${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$data" | head -1 | awk '{print $1}')

    echo "$data" | head -"$limit" | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d ${unit}${RESET}\n" "$name" "$count"
        fi
    done
}

# Display agent stats
show_agent_stats() {
    local period="${1:-week}"
    local display_period
    display_period=$(format_period "$period")
    local data
    data=$(count_agents "$period" 2>/dev/null)

    show_stats_section "📊 Top Agents ($display_period)" "$data" "calls" 5 "No agent data found - Agents are created when you use the Task tool"
}

# Display skill stats
show_skill_stats() {
    local period="${1:-week}"
    local data
    data=$(count_skills "$period" 2>/dev/null)

    show_stats_section "🔧 Top Skills" "$data" "uses" 5
}

# Display tool stats
show_tool_stats() {
    local period="${1:-week}"
    local data
    data=$(count_tools "$period" 2>/dev/null)

    show_stats_section "🛠️  Top Tools" "$data" "uses" 8
}

# Display unused items
show_unused() {
    local period="${1:-month}"
    local display_period
    display_period=$(format_period "$period")

    header "⚠️  Unused ($display_period)"

    local unused_agents
    local unused_skills
    unused_agents=$(find_unused_agents "$period" 2>/dev/null)
    unused_skills=$(find_unused_skills "$period" 2>/dev/null)

    if [[ -n "$unused_agents" ]]; then
        echo -e "  ${YELLOW}Unused Agents:${RESET}"
        echo "$unused_agents" | head -5 | while read -r agent; do
            [[ -n "$agent" ]] && echo -e "    └── ${DIM}$agent${RESET}"
        done
    fi

    if [[ -n "$unused_skills" ]]; then
        [[ -n "$unused_agents" ]] && echo ""
        echo -e "  ${YELLOW}Unused Skills:${RESET}"
        echo "$unused_skills" | head -5 | while read -r skill; do
            [[ -n "$skill" ]] && echo -e "    └── ${DIM}$skill${RESET}"
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

# Display Gemini CLI stats
show_gemini_stats() {
    local period="${1:-week}"
    local display_period
    display_period=$(format_period "$period")

    header "🔮 Gemini CLI ($display_period)"

    if ! has_gemini_telemetry; then
        echo -e "  ${DIM}Gemini telemetry not enabled${RESET}"
        echo ""
        echo -e "  ${DIM}To enable, add to ~/.gemini/settings.json:${RESET}"
        echo -e "  ${DIM}{\"telemetry\": {\"enabled\": true, \"target\": \"local\"}}${RESET}"
        return
    fi

    local data
    data=$(count_gemini_tools "$period" 2>/dev/null)

    if [[ -z "$data" ]]; then
        echo -e "  ${DIM}No Gemini tool usage found for this period${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$data" | head -1 | awk '{print $1}')

    echo "$data" | head -8 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d calls${RESET}\n" "$name" "$count"
        fi
    done

    local session_count
    local total_calls
    session_count=$(list_gemini_sessions "$period" 2>/dev/null)
    total_calls=$(count_gemini_total_calls "$period" 2>/dev/null)

    echo ""
    echo -e "  ${DIM}Sessions: $session_count | Total calls: $total_calls${RESET}"
}

# Display Codex CLI stats
show_codex_stats() {
    local period="${1:-week}"
    local display_period
    display_period=$(format_period "$period")

    header "🤖 Codex CLI ($display_period)"

    if ! has_codex_sessions; then
        echo -e "  ${DIM}No Codex CLI session data found${RESET}"
        echo ""
        echo -e "  ${DIM}Codex CLI stores sessions in ~/.codex/sessions/${RESET}"
        echo -e "  ${DIM}Use Codex CLI to generate session data${RESET}"
        return
    fi

    local data
    data=$(count_codex_tools "$period" 2>/dev/null)

    if [[ -z "$data" ]]; then
        echo -e "  ${DIM}No Codex tool usage found for this period${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$data" | head -1 | awk '{print $1}')

    echo "$data" | head -8 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d calls${RESET}\n" "$name" "$count"
        fi
    done

    local session_count
    local total_calls
    session_count=$(list_codex_sessions "$period" 2>/dev/null)
    total_calls=$(count_codex_total_calls "$period" 2>/dev/null)

    echo ""
    echo -e "  ${DIM}Sessions: $session_count | Total calls: $total_calls${RESET}"
}

# Display OpenCode stats
show_opencode_stats() {
    local period="${1:-week}"
    local display_period
    display_period=$(format_period "$period")

    header "🌐 OpenCode ($display_period)"

    if ! has_opencode_sessions; then
        echo -e "  ${DIM}No OpenCode session data found${RESET}"
        echo ""
        echo -e "  ${DIM}OpenCode stores data in ~/.local/share/opencode/storage/${RESET}"
        echo -e "  ${DIM}Use OpenCode to generate session data${RESET}"
        return
    fi

    local data
    data=$(count_opencode_tools "$period" 2>/dev/null)

    if [[ -z "$data" ]]; then
        echo -e "  ${DIM}No OpenCode tool usage found for this period${RESET}"
        return
    fi

    local max_count
    max_count=$(echo "$data" | head -1 | awk '{print $1}')

    echo "$data" | head -8 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d calls${RESET}\n" "$name" "$count"
        fi
    done

    local session_count
    local total_calls
    session_count=$(list_opencode_sessions "$period" 2>/dev/null)
    total_calls=$(count_opencode_total_calls "$period" 2>/dev/null)

    echo ""
    echo -e "  ${DIM}Sessions: $session_count | Total calls: $total_calls${RESET}"
}

# Display trend indicator
show_trend_indicator() {
    local change="$1"

    if [[ "$change" -gt 0 ]]; then
        echo -e "${GREEN}↑ +${change}%${RESET}"
    elif [[ "$change" -lt 0 ]]; then
        echo -e "${RED}↓ ${change}%${RESET}"
    else
        echo -e "${DIM}→ 0%${RESET}"
    fi
}

# Get total calls across all tools
get_all_tools_total() {
    local period="${1:-week}"
    local total=0

    # Claude
    local claude_calls
    claude_calls=$(count_total_calls "$period" 2>/dev/null)
    total=$((total + claude_calls))

    # Gemini
    if has_gemini_telemetry; then
        local gemini_calls
        gemini_calls=$(count_gemini_total_calls "$period" 2>/dev/null)
        total=$((total + gemini_calls))
    fi

    # Codex
    if has_codex_sessions; then
        local codex_calls
        codex_calls=$(count_codex_total_calls "$period" 2>/dev/null)
        total=$((total + codex_calls))
    fi

    # OpenCode
    if has_opencode_sessions; then
        local opencode_calls
        opencode_calls=$(count_opencode_total_calls "$period" 2>/dev/null)
        total=$((total + opencode_calls))
    fi

    echo "$total"
}

# Display trend summary
show_trend_summary() {
    local period="${1:-week}"

    # Only show trends for week or month
    [[ "$period" != "week" ]] && [[ "$period" != "month" ]] && return

    local trend_data
    trend_data=$(get_trend_data "$period")

    local current previous change
    current=$(echo "$trend_data" | cut -d'|' -f1)
    previous=$(echo "$trend_data" | cut -d'|' -f2)
    change=$(echo "$trend_data" | cut -d'|' -f3)

    local prev_label
    [[ "$period" == "week" ]] && prev_label="vs last week" || prev_label="vs last month"

    header "📈 Summary"

    # Show Claude stats
    printf "  Claude Code:  ${BOLD}%s${RESET} calls %s (%s: %s)\n" "$current" "$(show_trend_indicator "$change")" "$prev_label" "$previous"

    # Show total across all tools if other tools have data
    local total_current
    total_current=$(get_all_tools_total "$period")

    if [[ "$total_current" -gt "$current" ]]; then
        printf "  ${DIM}All tools:     ${RESET}${BOLD}%s${RESET} ${DIM}total calls${RESET}\n" "$total_current"
    fi
}

# Display compact stats for other tools (for dashboard)
show_other_tools_summary() {
    local period="${1:-week}"
    local has_any=false

    # Check if any other tools have data
    if has_gemini_telemetry || has_codex_sessions || has_opencode_sessions; then
        header "🔌 Other Tools"

        # Gemini
        if has_gemini_telemetry; then
            local gemini_calls
            gemini_calls=$(count_gemini_total_calls "$period" 2>/dev/null)
            if [[ "$gemini_calls" -gt 0 ]]; then
                printf "  ├── ${CYAN}Gemini CLI${RESET}     %s tool calls\n" "$gemini_calls"
                has_any=true
            fi
        fi

        # Codex
        if has_codex_sessions; then
            local codex_calls
            codex_calls=$(count_codex_total_calls "$period" 2>/dev/null)
            if [[ "$codex_calls" -gt 0 ]]; then
                printf "  ├── ${CYAN}Codex CLI${RESET}      %s tool calls\n" "$codex_calls"
                has_any=true
            fi
        fi

        # OpenCode
        if has_opencode_sessions; then
            local opencode_calls
            opencode_calls=$(count_opencode_total_calls "$period" 2>/dev/null)
            if [[ "$opencode_calls" -gt 0 ]]; then
                printf "  ├── ${CYAN}OpenCode${RESET}       %s tool calls\n" "$opencode_calls"
                has_any=true
            fi
        fi

        if [[ "$has_any" == "false" ]]; then
            echo -e "  ${DIM}No activity in this period${RESET}"
        fi

        echo -e "  ${DIM}Use 'wr gemini/codex/opencode' for details${RESET}"
    fi
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
    show_other_tools_summary "$period"
    echo ""
    show_trend_summary "$period"
    echo ""
}
