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
            show_dashboard_header "all time"
            echo ""
            show_agent_stats "all time"
            echo ""
            ;;
        "skills")
            show_dashboard_header "all time"
            echo ""
            show_skill_stats "all time"
            echo ""
            ;;
        "projects")
            show_dashboard_header "all time"
            echo ""
            show_project_breakdown
            echo ""
            ;;
        "clean")
            show_dashboard_header "cleanup"
            echo ""
            show_unused
            echo ""
            info "Run 'wr clean --apply' to remove unused items"
            ;;
        *)
            error "Unknown stats command: $command"
            exit 1
            ;;
    esac
}
