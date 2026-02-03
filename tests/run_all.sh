#!/bin/bash
# Run all tests
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  Running All Tests for who-ran-what"
echo "============================================"
echo ""

TOTAL_FAILED=0

for test_file in "$SCRIPT_DIR"/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        echo "Running: $(basename "$test_file")"
        echo ""
        if bash "$test_file"; then
            echo ""
        else
            echo ""
            echo "Test file failed: $test_file"
            ((TOTAL_FAILED++))
        fi
    fi
done

echo "============================================"
echo "  All Tests Complete"
echo "============================================"

if [[ "$TOTAL_FAILED" -gt 0 ]]; then
    echo "Some test files failed!"
    exit 1
fi

echo "All test files passed!"
exit 0
