#!/bin/bash
# Test suite for parser functions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASSED=0
FAILED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities first (for dependencies)
source "$PROJECT_DIR/lib/who-ran-what/utils/detect.sh"

# Source all parsers
source "$PROJECT_DIR/lib/who-ran-what/core/claude-parser.sh"
source "$PROJECT_DIR/lib/who-ran-what/core/gemini-parser.sh"
source "$PROJECT_DIR/lib/who-ran-what/core/codex-parser.sh"
source "$PROJECT_DIR/lib/who-ran-what/core/opencode-parser.sh"

test_function_exists() {
    local name="$1"
    local func="$2"

    if declare -f "$func" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name (function '$func' not found)"
        FAILED=$((FAILED + 1))
    fi
}

echo "========================================"
echo "  Parser Function Tests"
echo "========================================"
echo ""

echo "Testing: Core Functions"
echo "----------------------------------------"
test_function_exists "get_filter_date exists" "get_filter_date"
test_function_exists "find_session_files exists" "find_session_files"
test_function_exists "parse_claude_sessions exists" "parse_claude_sessions"

echo ""
echo "Testing: Count Functions"
echo "----------------------------------------"
test_function_exists "count_agents exists" "count_agents"
test_function_exists "count_skills exists" "count_skills"
test_function_exists "count_tools exists" "count_tools"

echo ""
echo "Testing: Analysis Functions"
echo "----------------------------------------"
test_function_exists "find_unused_agents exists" "find_unused_agents"
test_function_exists "find_unused_skills exists" "find_unused_skills"
test_function_exists "list_projects exists" "list_projects"
test_function_exists "get_usage_summary exists" "get_usage_summary"

echo ""
echo "Testing: Gemini Parser Functions"
echo "----------------------------------------"
test_function_exists "has_gemini_telemetry exists" "has_gemini_telemetry"
test_function_exists "find_gemini_entries exists" "find_gemini_entries"
test_function_exists "count_gemini_tools exists" "count_gemini_tools"
test_function_exists "count_gemini_total_calls exists" "count_gemini_total_calls"
test_function_exists "list_gemini_sessions exists" "list_gemini_sessions"

echo ""
echo "Testing: Codex Parser Functions"
echo "----------------------------------------"
test_function_exists "has_codex_sessions exists" "has_codex_sessions"
test_function_exists "find_codex_session_files exists" "find_codex_session_files"
test_function_exists "count_codex_tools exists" "count_codex_tools"
test_function_exists "count_codex_total_calls exists" "count_codex_total_calls"
test_function_exists "list_codex_sessions exists" "list_codex_sessions"

echo ""
echo "Testing: OpenCode Parser Functions"
echo "----------------------------------------"
test_function_exists "has_opencode_sessions exists" "has_opencode_sessions"
test_function_exists "find_opencode_part_files exists" "find_opencode_part_files"
test_function_exists "count_opencode_tools exists" "count_opencode_tools"
test_function_exists "count_opencode_total_calls exists" "count_opencode_total_calls"
test_function_exists "list_opencode_sessions exists" "list_opencode_sessions"

echo ""
echo "========================================"
echo "  Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0
