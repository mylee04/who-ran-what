#!/bin/bash

# Error handling utilities for who-ran-what

# Error codes (exported for external use)
# shellcheck disable=SC2034
readonly ERR_NO_DATA=10
readonly ERR_NO_CLAUDE_DIR=11
readonly ERR_INVALID_COMMAND=12
readonly ERR_INVALID_PERIOD=13
readonly ERR_CONFIG_PARSE=14

# Show error with suggestion
show_error() {
    local message="$1"
    local suggestion="${2:-}"

    echo -e "${RED}[X]${RESET} Error: $message" >&2

    if [[ -n "$suggestion" ]]; then
        echo -e "    ${DIM}Suggestion: $suggestion${RESET}" >&2
    fi
}

# Check if Claude data directory exists
check_claude_data() {
    local claude_dir="$HOME/.claude/projects"

    if [[ ! -d "$claude_dir" ]]; then
        show_error "Claude Code data directory not found" \
            "Make sure Claude Code is installed and you've used it at least once"
        echo ""
        echo "Expected location: $claude_dir"
        echo ""
        echo "To get started with Claude Code:"
        echo "  1. Install Claude Code: npm install -g @anthropic/claude-code"
        echo "  2. Run claude in any project directory"
        echo "  3. Use it for a while to generate session data"
        return $ERR_NO_CLAUDE_DIR
    fi

    # Check if there are any session files
    local session_count
    session_count=$(find "$claude_dir" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$session_count" -eq 0 ]]; then
        show_error "No Claude Code session data found" \
            "Use Claude Code in some projects first"
        echo ""
        echo "Your Claude data directory exists but has no session files."
        echo "Session files are created when you use Claude Code."
        return $ERR_NO_DATA
    fi

    return 0
}

# Validate period argument
validate_period() {
    local period="$1"

    case "$period" in
        "today"|"week"|"month"|"all")
            return 0
            ;;
        *)
            show_error "Invalid period: $period" \
                "Use one of: today, week, month, all"
            return $ERR_INVALID_PERIOD
            ;;
    esac
}

# Handle missing jq gracefully
check_jq_available() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}[!]${RESET} jq not installed - using basic parsing" >&2
        echo -e "    ${DIM}Install jq for better accuracy: brew install jq${RESET}" >&2
        return 1
    fi
    return 0
}

# Safe wrapper for commands that might fail
# Usage: safe_run "fallback_value" command arg1 arg2 ...
safe_run() {
    local fallback="${1:-}"
    shift

    local result
    if result=$("$@" 2>/dev/null); then
        echo "$result"
    elif [[ -n "$fallback" ]]; then
        echo "$fallback"
    else
        echo ""
    fi
}

# Graceful exit handler
graceful_exit() {
    local code="${1:-0}"
    local message="${2:-}"

    if [[ -n "$message" ]]; then
        if [[ "$code" -eq 0 ]]; then
            echo -e "${GREEN}[OK]${RESET} $message"
        else
            echo -e "${RED}[X]${RESET} $message" >&2
        fi
    fi

    exit "$code"
}
