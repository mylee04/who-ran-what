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

# Source the parser
source "$PROJECT_DIR/lib/who-ran-what/core/claude-parser.sh"

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
echo "========================================"
echo "  Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0
