#!/bin/bash

# Project command handler for who-ran-what

handle_project_command() {
    local command="${1:-status}"
    local project_name=$(get_project_name)
    local project_root=$(get_project_root)

    header "📁 Project: $project_name"
    dim "   $project_root"
    echo ""

    case "$command" in
        "status"|"")
            show_project_stats "$project_name"
            ;;
        "agents")
            show_project_agents "$project_name"
            ;;
        "skills")
            show_project_skills "$project_name"
            ;;
        *)
            error "Unknown project command: $command"
            echo "Try 'wrp help' for usage"
            exit 1
            ;;
    esac
}

show_project_stats() {
    local project="$1"

    echo -e "${BOLD}Stats for $project${RESET}"
    echo ""

    # TODO: Replace with actual data
    echo -e "  Total sessions:     ${CYAN}47${RESET}"
    echo -e "  Agent calls:        ${CYAN}234${RESET}"
    echo -e "  Skill uses:         ${CYAN}189${RESET}"
    echo -e "  Most used agent:    ${GREEN}Sisyphus${RESET}"
    echo -e "  Most used skill:    ${GREEN}git-master${RESET}"
    echo ""
}

show_project_agents() {
    local project="$1"

    header "📊 Agents in $project"

    # TODO: Replace with actual data
    echo -e "  ├── Sisyphus      $(draw_bar 180 200)  ${CYAN}180 calls${RESET}"
    echo -e "  ├── Oracle        $(draw_bar 34 200)   ${CYAN}34 calls${RESET}"
    echo -e "  └── Explore       $(draw_bar 20 200)   ${CYAN}20 calls${RESET}"
    echo ""
}

show_project_skills() {
    local project="$1"

    header "🔧 Skills in $project"

    # TODO: Replace with actual data
    echo -e "  ├── git-master    $(draw_bar 89 100)  ${CYAN}89 uses${RESET}"
    echo -e "  ├── commit        $(draw_bar 67 100)  ${CYAN}67 uses${RESET}"
    echo -e "  └── review        $(draw_bar 33 100)  ${CYAN}33 uses${RESET}"
    echo ""
}
