#!/bin/bash

# Detection utilities for who-ran-what

# Calculate date with offset (cross-platform)
# Usage: calculate_date_offset 7 -> date 7 days ago
calculate_date_offset() {
    local days="$1"
    local os_type
    os_type=$(uname -s)

    if [[ "$os_type" == "Darwin" ]]; then
        date -v"-${days}d" +%Y-%m-%d
    else
        date -d "$days days ago" +%Y-%m-%d
    fi
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# Get project name from git or folder
get_project_name() {
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
        basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || basename "$PWD"
    else
        basename "$PWD"
    fi
}

# Get project root
get_project_root() {
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
        git rev-parse --show-toplevel 2>/dev/null || echo "$PWD"
    else
        echo "$PWD"
    fi
}

# Data source paths
CLAUDE_DATA_DIR="$HOME/.claude/projects"
OPENCODE_DATA_DIR="$HOME/.local/share/opencode/storage"
CODEX_DATA_DIR="$HOME/.codex/sessions"
GEMINI_DATA_DIR="$HOME/.gemini"

# Check if data source exists
has_claude_data() {
    [[ -d "$CLAUDE_DATA_DIR" ]]
}

has_opencode_data() {
    [[ -d "$OPENCODE_DATA_DIR" ]]
}

has_codex_data() {
    [[ -d "$CODEX_DATA_DIR" ]]
}

has_gemini_data() {
    [[ -d "$GEMINI_DATA_DIR" ]]
}

# Check if Gemini CLI is installed
detect_gemini() {
    command -v gemini &> /dev/null
}

# Check if Gemini telemetry file exists and has data
has_gemini_telemetry() {
    local telemetry_file="$GEMINI_DATA_DIR/telemetry.log"
    [[ -f "$telemetry_file" ]] && [[ -s "$telemetry_file" ]]
}
