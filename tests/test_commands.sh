#!/bin/bash
# Test suite for who-ran-what CLI

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN="$PROJECT_DIR/bin/who-ran-what"

# Test helper function
test_command() {
    local name="$1"
    local cmd="$2"
    local expected_exit="${3:-0}"

    if eval "$cmd" > /dev/null 2>&1; then
        actual_exit=0
    else
        actual_exit=$?
    fi

    if [[ "$actual_exit" -eq "$expected_exit" ]]; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name (expected exit $expected_exit, got $actual_exit)"
        FAILED=$((FAILED + 1))
    fi
}

# Test output contains string
test_output_contains() {
    local name="$1"
    local cmd="$2"
    local expected="$3"

    if eval "$cmd" 2>&1 | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name (output should contain '$expected')"
        FAILED=$((FAILED + 1))
    fi
}

echo "========================================"
echo "  who-ran-what Test Suite"
echo "========================================"
echo ""

# Check if binary exists
if [[ ! -x "$BIN" ]]; then
    echo -e "${RED}Error: $BIN not found or not executable${NC}"
    exit 1
fi

echo "Testing: Basic Commands"
echo "----------------------------------------"
test_command "version command exits 0" "$BIN version"
test_command "help command exits 0" "$BIN help"
test_command "default (no args) exits 0" "$BIN"

echo ""
echo "Testing: Time-based Commands"
echo "----------------------------------------"
test_command "today command exits 0" "$BIN today"
test_command "week command exits 0" "$BIN week"
test_command "month command exits 0" "$BIN month"

echo ""
echo "Testing: Stats Commands"
echo "----------------------------------------"
test_command "agents command exits 0" "$BIN agents"
test_command "skills command exits 0" "$BIN skills"
test_command "projects command exits 0" "$BIN projects"
test_command "gemini command exits 0" "$BIN gemini"
test_command "codex command exits 0" "$BIN codex"
test_command "opencode command exits 0" "$BIN opencode"
test_command "clean command exits 0" "$BIN clean"

echo ""
echo "Testing: Project Commands"
echo "----------------------------------------"
test_command "project command exits 0" "$BIN project"

echo ""
echo "Testing: Output Content"
echo "----------------------------------------"
test_output_contains "version shows version number" "$BIN version" "0.1.1"
test_output_contains "help shows USAGE" "$BIN help" "USAGE"
test_output_contains "help shows COMMANDS" "$BIN help" "COMMANDS"

echo ""
echo "Testing: Invalid Commands"
echo "----------------------------------------"
test_command "invalid command exits non-zero" "$BIN invalid-command-xyz" 1

echo ""
echo "========================================"
echo "  Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0
