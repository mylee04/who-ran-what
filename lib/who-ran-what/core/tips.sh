#!/bin/bash

# Tips and suggestions based on usage patterns
# Helps users optimize their AI coding workflow

# Thresholds for tips
readonly TIP_LOW_AGENT_DIVERSITY=3
readonly TIP_LOW_SKILL_COUNT=2
readonly TIP_EXPLORE_DOMINANT_PCT=70

# Get usage tips based on current stats
get_usage_tips() {
    local period="${1:-week}"
    local tips=()

    # Get stats
    local agent_count
    local skill_count
    local total_agent_calls
    local explore_calls

    agent_count=$(count_agents "$period" 2>/dev/null | wc -l | tr -d ' ')
    skill_count=$(count_skills "$period" 2>/dev/null | wc -l | tr -d ' ')
    total_agent_calls=$(count_agents "$period" 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    explore_calls=$(count_agents "$period" 2>/dev/null | grep -w "Explore" | awk '{print $1}')
    explore_calls=${explore_calls:-0}

    # Tip 1: Low agent diversity
    if [[ "$agent_count" -lt "$TIP_LOW_AGENT_DIVERSITY" ]]; then
        tips+=("agent_diversity")
    fi

    # Tip 2: No skills used
    if [[ "$skill_count" -lt "$TIP_LOW_SKILL_COUNT" ]]; then
        tips+=("no_skills")
    fi

    # Tip 3: Explore dominant (over 70%)
    if [[ "$total_agent_calls" -gt 0 ]]; then
        local explore_pct=$((explore_calls * 100 / total_agent_calls))
        if [[ "$explore_pct" -gt "$TIP_EXPLORE_DOMINANT_PCT" ]]; then
            tips+=("explore_dominant")
        fi
    fi

    # Tip 4: No custom agents (only using built-in ones)
    local builtin_agents
    builtin_agents=$(count_agents "$period" 2>/dev/null | grep -c -E "(Explore|Plan|general-purpose|code-reviewer|test-engineer)" || echo "0")
    builtin_agents=$(echo "$builtin_agents" | tr -d '[:space:]')
    if [[ "$builtin_agents" -eq "$agent_count" ]] && [[ "$agent_count" -gt 0 ]]; then
        tips+=("no_custom_agents")
    fi

    # Output tips
    for tip in "${tips[@]}"; do
        echo "$tip"
    done
}

# Display tips with explanations
show_tips() {
    local period="${1:-week}"
    local tips
    tips=$(get_usage_tips "$period")

    if [[ -z "$tips" ]]; then
        return
    fi

    header "💡 Tips to Improve Your Workflow"

    while IFS= read -r tip; do
        case "$tip" in
            "agent_diversity")
                echo -e "  ${YELLOW}Low agent diversity${RESET}"
                echo -e "  Try using specialized agents like:"
                echo -e "    ${CYAN}•${RESET} code-reviewer - for code reviews"
                echo -e "    ${CYAN}•${RESET} test-engineer - for writing tests"
                echo -e "    ${CYAN}•${RESET} security-auditor - for security checks"
                echo ""
                ;;
            "no_skills")
                echo -e "  ${YELLOW}Skills not being used${RESET}"
                echo -e "  Skills (slash commands) can speed up your workflow:"
                echo -e "    ${CYAN}•${RESET} /commit - create well-formatted commits"
                echo -e "    ${CYAN}•${RESET} /review - quick code review"
                echo -e "    ${CYAN}•${RESET} Define custom skills in .claude/commands/"
                echo ""
                ;;
            "explore_dominant")
                echo -e "  ${YELLOW}Explore agent is ${BOLD}>${TIP_EXPLORE_DOMINANT_PCT}%${RESET}${YELLOW} of usage${RESET}"
                echo -e "  Consider using Plan agent for complex tasks:"
                echo -e "    ${CYAN}•${RESET} Plan helps break down multi-step work"
                echo -e "    ${CYAN}•${RESET} Use when implementing new features"
                echo ""
                ;;
            "no_custom_agents")
                echo -e "  ${YELLOW}No custom agents used${RESET}"
                echo -e "  Create project-specific agents in .claude/agents/:"
                echo -e "    ${CYAN}•${RESET} Specialized for your codebase"
                echo -e "    ${CYAN}•${RESET} Include project conventions"
                echo -e "    ${CYAN}•${RESET} Reference: .claude/agents/example.md"
                echo ""
                ;;
        esac
    done <<< "$tips"

    echo -e "  ${CYAN}Learn more:${RESET} https://github.com/mylee04/who-ran-what"
}

# Show tips in JSON format
generate_tips_json() {
    local period="${1:-week}"
    local tips
    tips=$(get_usage_tips "$period")

    local tips_array="[]"
    if [[ -n "$tips" ]]; then
        tips_array="["
        local first=true
        while IFS= read -r tip; do
            [[ -z "$tip" ]] && continue
            if [[ "$first" == "true" ]]; then
                first=false
            else
                tips_array+=","
            fi

            local message=""
            local suggestion=""
            case "$tip" in
                "agent_diversity")
                    message="Low agent diversity"
                    suggestion="Try specialized agents: code-reviewer, test-engineer, security-auditor"
                    ;;
                "no_skills")
                    message="Skills not being used"
                    suggestion="Use /commit, /review, or create custom skills in .claude/commands/"
                    ;;
                "explore_dominant")
                    message="Explore agent dominates usage"
                    suggestion="Use Plan agent for complex multi-step tasks"
                    ;;
                "no_custom_agents")
                    message="No custom agents used"
                    suggestion="Create project-specific agents in .claude/agents/"
                    ;;
            esac

            tips_array+="{\"type\":\"$tip\",\"message\":\"$message\",\"suggestion\":\"$suggestion\"}"
        done <<< "$tips"
        tips_array+="]"
    fi

    echo "$tips_array"
}

# Handle tips command
handle_tips_command() {
    local period="${1:-week}"

    if [[ "$JSON_OUTPUT" == "true" ]]; then
        cat << EOF
{
  "period": "$period",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tips": $(generate_tips_json "$period")
}
EOF
    else
        show_dashboard_header "$period"
        echo ""
        show_tips "$period"

        local tips
        tips=$(get_usage_tips "$period")
        if [[ -z "$tips" ]]; then
            echo -e "  ${GREEN}Great job! No suggestions at this time.${RESET}"
            echo ""
        fi
    fi
}
