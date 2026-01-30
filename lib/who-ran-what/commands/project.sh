#!/bin/bash

# Project command handler for who-ran-what

handle_project_command() {
    local command="${1:-status}"
    local project_name
    local project_root

    project_name=$(get_project_name)
    project_root=$(get_project_root)

    header "📁 Project: $project_name"
    dim "   $project_root"
    echo ""

    case "$command" in
        "status"|"")
            show_project_stats "$project_root"
            ;;
        "agents")
            show_project_agents "$project_root"
            ;;
        "skills")
            show_project_skills "$project_root"
            ;;
        *)
            error "Unknown project command: $command"
            echo "Try 'wrp help' for usage"
            exit 1
            ;;
    esac
}

# Get Claude project directory path
get_claude_project_path() {
    local project_root="$1"
    local claude_project_dir
    claude_project_dir=$(echo "$project_root" | sed 's|/|-|g; s|^-||')
    echo "$CLAUDE_PROJECTS_DIR/-$claude_project_dir"
}

# Count agents for a specific project
count_project_agents() {
    local project_path="$1"
    local claude_path
    claude_path=$(get_claude_project_path "$project_path")

    if [[ ! -d "$claude_path" ]]; then
        return
    fi

    grep -h '"name":"Task"' "$claude_path"/*.jsonl 2>/dev/null | \
    grep -o '"subagent_type":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count skills for a specific project
count_project_skills() {
    local project_path="$1"
    local claude_path
    claude_path=$(get_claude_project_path "$project_path")

    if [[ ! -d "$claude_path" ]]; then
        return
    fi

    grep -h '"name":"Skill"' "$claude_path"/*.jsonl 2>/dev/null | \
    grep -o '"skill":"[^"]*"' | \
    cut -d'"' -f4 | \
    sort | uniq -c | sort -rn
}

# Count tools for a specific project
count_project_tools() {
    local project_path="$1"
    local claude_path
    claude_path=$(get_claude_project_path "$project_path")

    if [[ ! -d "$claude_path" ]]; then
        return
    fi

    grep -oh '"type":"tool_use"' "$claude_path"/*.jsonl 2>/dev/null | wc -l | tr -d ' '
}

# Count sessions for a specific project
count_project_sessions() {
    local project_path="$1"
    local claude_path
    claude_path=$(get_claude_project_path "$project_path")

    if [[ ! -d "$claude_path" ]]; then
        echo "0"
        return
    fi

    find "$claude_path" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' '
}

show_project_stats() {
    local project_root="$1"

    echo -e "${BOLD}Stats${RESET}"
    echo ""

    local sessions
    local agent_data
    local skill_data
    local tool_count
    local top_agent
    local top_skill

    sessions=$(count_project_sessions "$project_root")
    agent_data=$(count_project_agents "$project_root")
    skill_data=$(count_project_skills "$project_root")
    tool_count=$(count_project_tools "$project_root")

    # Get totals
    local agent_total=0
    local skill_total=0

    if [[ -n "$agent_data" ]]; then
        agent_total=$(echo "$agent_data" | awk '{sum += $1} END {print sum}')
        top_agent=$(echo "$agent_data" | head -1 | awk '{print $2}')
    fi

    if [[ -n "$skill_data" ]]; then
        skill_total=$(echo "$skill_data" | awk '{sum += $1} END {print sum}')
        top_skill=$(echo "$skill_data" | head -1 | awk '{print $2}')
    fi

    echo -e "  Total sessions:     ${CYAN}$sessions${RESET}"
    echo -e "  Tool calls:         ${CYAN}$tool_count${RESET}"
    echo -e "  Agent calls:        ${CYAN}${agent_total:-0}${RESET}"
    echo -e "  Skill uses:         ${CYAN}${skill_total:-0}${RESET}"

    if [[ -n "$top_agent" ]]; then
        echo -e "  Most used agent:    ${GREEN}$top_agent${RESET}"
    fi

    if [[ -n "$top_skill" ]]; then
        echo -e "  Most used skill:    ${GREEN}$top_skill${RESET}"
    fi

    echo ""
}

show_project_agents() {
    local project_root="$1"

    header "📊 Agents"

    local agent_data
    agent_data=$(count_project_agents "$project_root")

    if [[ -z "$agent_data" ]]; then
        echo -e "  ${DIM}No agent data found${RESET}"
        echo ""
        return
    fi

    local max_count
    max_count=$(echo "$agent_data" | head -1 | awk '{print $1}')

    echo "$agent_data" | head -5 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d calls${RESET}\n" "$name" "$count"
        fi
    done
    echo ""
}

show_project_skills() {
    local project_root="$1"

    header "🔧 Skills"

    local skill_data
    skill_data=$(count_project_skills "$project_root")

    if [[ -z "$skill_data" ]]; then
        echo -e "  ${DIM}No skill data found${RESET}"
        echo ""
        return
    fi

    local max_count
    max_count=$(echo "$skill_data" | head -1 | awk '{print $1}')

    echo "$skill_data" | head -5 | while read -r count name; do
        if [[ -n "$name" ]]; then
            printf "  ├── %-12s $(draw_bar "$count" "$max_count")  ${CYAN}%d uses${RESET}\n" "$name" "$count"
        fi
    done
    echo ""
}
