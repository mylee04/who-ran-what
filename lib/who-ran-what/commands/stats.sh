#!/bin/bash

# Stats command handler for who-ran-what

handle_stats_command() {
    local command="${1:-dashboard}"

    case "$command" in
        "dashboard")
            show_dashboard "week"
            ;;
        "today")
            show_dashboard "today"
            ;;
        "week")
            show_dashboard "week"
            ;;
        "month")
            show_dashboard "month"
            ;;
        "agents")
            show_dashboard_header "all"
            echo ""
            show_agent_stats "all"
            echo ""
            ;;
        "skills")
            show_dashboard_header "all"
            echo ""
            show_skill_stats "all"
            echo ""
            ;;
        "projects")
            show_dashboard_header "all"
            echo ""
            show_project_breakdown "all"
            echo ""
            ;;
        "clean")
            show_dashboard_header "month"
            echo ""
            show_unused "month"
            echo ""
            dim "Unused agents/skills are not used in the past 30 days"
            ;;
        *)
            error "Unknown stats command: $command"
            exit 1
            ;;
    esac
}
