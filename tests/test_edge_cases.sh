#!/bin/bash
# Edge case tests for who-ran-what

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASSED=0
FAILED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN="$PROJECT_DIR/bin/who-ran-what"

test_pass() {
    local name="$1"
    echo -e "${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
}

test_fail() {
    local name="$1"
    local reason="$2"
    echo -e "${RED}✗${NC} $name ($reason)"
    FAILED=$((FAILED + 1))
}

echo "========================================"
echo "  Edge Case Tests"
echo "========================================"
echo ""

echo "Testing: JSON Output"
echo "----------------------------------------"

# Test JSON output is valid
json_output=$("$BIN" --json 2>&1)
if echo "$json_output" | jq . > /dev/null 2>&1; then
    test_pass "Dashboard JSON is valid"
else
    test_fail "Dashboard JSON is valid" "invalid JSON"
fi

# Test agents JSON
agents_json=$("$BIN" agents --json 2>&1)
if echo "$agents_json" | jq . > /dev/null 2>&1; then
    test_pass "Agents JSON is valid"
else
    test_fail "Agents JSON is valid" "invalid JSON"
fi

# Test JSON has required fields
if echo "$json_output" | jq -e '.version' > /dev/null 2>&1; then
    test_pass "JSON has version field"
else
    test_fail "JSON has version field" "missing field"
fi

if echo "$json_output" | jq -e '.period' > /dev/null 2>&1; then
    test_pass "JSON has period field"
else
    test_fail "JSON has period field" "missing field"
fi

if echo "$json_output" | jq -e '.agents' > /dev/null 2>&1; then
    test_pass "JSON has agents field"
else
    test_fail "JSON has agents field" "missing field"
fi

if echo "$json_output" | jq -e '.trend' > /dev/null 2>&1; then
    test_pass "JSON has trend field"
else
    test_fail "JSON has trend field" "missing field"
fi

echo ""
echo "Testing: Flag Combinations"
echo "----------------------------------------"

# Test -j shorthand
if "$BIN" -j 2>&1 | jq . > /dev/null 2>&1; then
    test_pass "-j shorthand works"
else
    test_fail "-j shorthand works" "failed"
fi

# Test --json with command
if "$BIN" week --json 2>&1 | jq . > /dev/null 2>&1; then
    test_pass "--json with week command works"
else
    test_fail "--json with week command works" "failed"
fi

# Test --json before command
if "$BIN" --json week 2>&1 | jq . > /dev/null 2>&1; then
    test_pass "--json before command works"
else
    test_fail "--json before command works" "failed"
fi

echo ""
echo "Testing: Config Command"
echo "----------------------------------------"

# Test config command
if "$BIN" config 2>&1 | grep -q "Configuration"; then
    test_pass "Config command shows configuration"
else
    test_fail "Config command shows configuration" "missing output"
fi

if "$BIN" config 2>&1 | grep -q "default_period"; then
    test_pass "Config shows default_period"
else
    test_fail "Config shows default_period" "missing field"
fi

echo ""
echo "Testing: Help Content"
echo "----------------------------------------"

# Test help includes --json
if "$BIN" help 2>&1 | grep -q "\-\-json"; then
    test_pass "Help shows --json flag"
else
    test_fail "Help shows --json flag" "missing"
fi

# Test help includes config
if "$BIN" help 2>&1 | grep -q "config"; then
    test_pass "Help shows config command"
else
    test_fail "Help shows config command" "missing"
fi

echo ""
echo "========================================"
echo "  Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0
