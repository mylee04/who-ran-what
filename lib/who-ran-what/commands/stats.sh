#!/bin/bash

# Stats command handler for who-ran-what

handle_stats_command() {
    local command="${1:-dashboard}"

    case "$command" in
        "dashboard")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_dashboard_json "$CONFIG_DEFAULT_PERIOD"
            else
                show_dashboard "$CONFIG_DEFAULT_PERIOD"
            fi
            ;;
        "today")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_dashboard_json "today"
            else
                show_dashboard "today"
            fi
            ;;
        "week")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_dashboard_json "week"
            else
                show_dashboard "week"
            fi
            ;;
        "month")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_dashboard_json "month"
            else
                show_dashboard "month"
            fi
            ;;
        "agents")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_agents_json "all"
            else
                show_dashboard_header "all"
                echo ""
                show_agent_stats "all"
                echo ""
            fi
            ;;
        "skills")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_skills_json "all"
            else
                show_dashboard_header "all"
                echo ""
                show_skill_stats "all"
                echo ""
            fi
            ;;
        "projects")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_projects_json "all"
            else
                show_dashboard_header "all"
                echo ""
                show_project_breakdown "all"
                echo ""
            fi
            ;;
        "clean")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_unused_json "month"
            else
                show_dashboard_header "month"
                echo ""
                show_unused "month"
                echo ""
                dim "Unused agents/skills are not used in the past 30 days"
            fi
            ;;
        "gemini")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_gemini_json "$CONFIG_DEFAULT_PERIOD"
            else
                show_dashboard_header "$CONFIG_DEFAULT_PERIOD"
                echo ""
                show_gemini_stats "$CONFIG_DEFAULT_PERIOD"
                echo ""
            fi
            ;;
        "codex")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_codex_json "$CONFIG_DEFAULT_PERIOD"
            else
                show_dashboard_header "$CONFIG_DEFAULT_PERIOD"
                echo ""
                show_codex_stats "$CONFIG_DEFAULT_PERIOD"
                echo ""
            fi
            ;;
        "opencode")
            if [[ "$JSON_OUTPUT" == "true" ]]; then
                generate_opencode_json "$CONFIG_DEFAULT_PERIOD"
            else
                show_dashboard_header "$CONFIG_DEFAULT_PERIOD"
                echo ""
                show_opencode_stats "$CONFIG_DEFAULT_PERIOD"
                echo ""
            fi
            ;;
        *)
            error "Unknown stats command: $command"
            exit 1
            ;;
    esac
}
