#!/bin/bash

# Configuration loader for who-ran-what
# Supports ~/.who-ran-what.yml or ~/.config/who-ran-what/config.yml

# Default configuration values
CONFIG_DEFAULT_PERIOD="week"
CONFIG_SHOW_TREND="true"
CONFIG_MAX_ITEMS="5"
CONFIG_IGNORED_AGENTS=""
CONFIG_IGNORED_SKILLS=""

# Config file locations (in order of priority)
CONFIG_PATHS=(
    "$HOME/.who-ran-what.yml"
    "$HOME/.who-ran-what.yaml"
    "$HOME/.config/who-ran-what/config.yml"
    "$HOME/.config/who-ran-what/config.yaml"
)

# Find config file
find_config_file() {
    for path in "${CONFIG_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    echo ""
}

# Parse simple YAML value (key: value format)
parse_yaml_value() {
    local file="$1"
    local key="$2"
    local default="$3"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local value
    value=$(grep "^${key}:" "$file" 2>/dev/null | head -1 | sed 's/^[^:]*:[[:space:]]*//' | tr -d '"' | tr -d "'")

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Parse YAML list (returns space-separated values)
parse_yaml_list() {
    local file="$1"
    local key="$2"

    if [[ ! -f "$file" ]]; then
        echo ""
        return
    fi

    # Check if key exists
    if ! grep -q "^${key}:" "$file" 2>/dev/null; then
        echo ""
        return
    fi

    # Extract list items (lines starting with -)
    local in_list=false
    local items=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^${key}: ]]; then
            in_list=true
            continue
        fi

        if [[ "$in_list" == "true" ]]; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]* ]]; then
                local item
                item=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d '"' | tr -d "'")
                items="$items $item"
            elif [[ "$line" =~ ^[a-zA-Z] ]]; then
                # New key, stop
                break
            fi
        fi
    done < "$file"

    echo "$items" | xargs  # Trim whitespace
}

# Load configuration
load_config() {
    local config_file
    config_file=$(find_config_file)

    if [[ -n "$config_file" ]]; then
        CONFIG_DEFAULT_PERIOD=$(parse_yaml_value "$config_file" "default_period" "$CONFIG_DEFAULT_PERIOD")
        CONFIG_SHOW_TREND=$(parse_yaml_value "$config_file" "show_trend" "$CONFIG_SHOW_TREND")
        CONFIG_MAX_ITEMS=$(parse_yaml_value "$config_file" "max_items" "$CONFIG_MAX_ITEMS")
        CONFIG_IGNORED_AGENTS=$(parse_yaml_list "$config_file" "ignored_agents")
        CONFIG_IGNORED_SKILLS=$(parse_yaml_list "$config_file" "ignored_skills")
    fi
}

# Check if an agent should be ignored
is_agent_ignored() {
    local agent="$1"

    if [[ -z "$CONFIG_IGNORED_AGENTS" ]]; then
        return 1
    fi

    for ignored in $CONFIG_IGNORED_AGENTS; do
        if [[ "$agent" == "$ignored" ]]; then
            return 0
        fi
    done

    return 1
}

# Check if a skill should be ignored
is_skill_ignored() {
    local skill="$1"

    if [[ -z "$CONFIG_IGNORED_SKILLS" ]]; then
        return 1
    fi

    for ignored in $CONFIG_IGNORED_SKILLS; do
        if [[ "$skill" == "$ignored" ]]; then
            return 0
        fi
    done

    return 1
}

# Show current config (for debugging)
show_config() {
    local config_file
    config_file=$(find_config_file)

    echo "Configuration:"
    echo "  Config file: ${config_file:-<none>}"
    echo "  default_period: $CONFIG_DEFAULT_PERIOD"
    echo "  show_trend: $CONFIG_SHOW_TREND"
    echo "  max_items: $CONFIG_MAX_ITEMS"
    echo "  ignored_agents: ${CONFIG_IGNORED_AGENTS:-<none>}"
    echo "  ignored_skills: ${CONFIG_IGNORED_SKILLS:-<none>}"
}

# Initialize config on source
load_config
