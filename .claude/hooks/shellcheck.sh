#!/bin/bash

# Run shellcheck on shell scripts after editing

file="$1"

# Only check .sh files or shell scripts
if [[ "$file" == *.sh ]] || head -1 "$file" 2>/dev/null | grep -q '^#!/.*sh'; then
    if command -v shellcheck &> /dev/null; then
        shellcheck "$file" 2>&1 || true
    fi
fi
