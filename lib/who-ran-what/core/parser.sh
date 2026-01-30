#!/bin/bash

# Data parsing for who-ran-what

# Parse Claude Code session logs for agent/skill usage
parse_claude_sessions() {
    local start_date="${1:-}"
    local end_date="${2:-}"

    # TODO: Implement Claude session parsing
    # Look for Task tool calls, Skill invocations, agent spawns
    echo "Parsing Claude sessions..."
}

# Parse OpenCode sessions
parse_opencode_sessions() {
    local start_date="${1:-}"
    local end_date="${2:-}"

    # TODO: Implement OpenCode session parsing
    echo "Parsing OpenCode sessions..."
}

# Aggregate agent usage data
aggregate_agent_usage() {
    local period="${1:-week}"

    # TODO: Implement aggregation logic
    # Return: agent_name, call_count, last_used
    echo "Aggregating agent usage..."
}

# Aggregate skill usage data
aggregate_skill_usage() {
    local period="${1:-week}"

    # TODO: Implement aggregation logic
    # Return: skill_name, use_count, last_used
    echo "Aggregating skill usage..."
}

# Find unused agents/skills
find_unused() {
    local days_threshold="${1:-30}"

    # TODO: Find agents/skills not used in N days
    echo "Finding unused items..."
}
