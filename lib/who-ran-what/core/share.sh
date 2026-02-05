#!/bin/bash

# Share image generator for who-ran-what
# Generates SVG image of usage stats for social sharing

# Generate share image
generate_share_image() {
    local period="${1:-week}"
    local output_file="${2:-}"
    # Future: support PNG format with imagemagick
    # local format="${3:-svg}"

    # Default output file
    if [[ -z "$output_file" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        output_file="$HOME/who-ran-what-stats-${timestamp}.svg"
    fi

    # Get stats data
    local agents_data
    local tools_data
    local total_calls

    agents_data=$(count_agents "$period" 2>/dev/null | head -5)
    tools_data=$(count_tools "$period" 2>/dev/null | head -5)
    total_calls=$(count_total_calls "$period" 2>/dev/null)

    # Get period display name
    local period_display
    case "$period" in
        "today") period_display="Today" ;;
        "week") period_display="This Week" ;;
        "month") period_display="This Month" ;;
        "all") period_display="All Time" ;;
        *) period_display="$period" ;;
    esac

    # Generate SVG
    generate_svg "$period_display" "$agents_data" "$tools_data" "$total_calls" > "$output_file"

    echo "$output_file"
}

# Generate SVG content
generate_svg() {
    local period="$1"
    local agents_data="$2"
    local tools_data="$3"
    local total_calls="$4"

    # SVG dimensions
    local width=600
    local height=400

    # Colors
    local bg_color="#1a1b26"
    local card_color="#24283b"
    local text_color="#c0caf5"
    local accent_color="#7aa2f7"
    local green_color="#9ece6a"
    local purple_color="#bb9af7"

    # Start SVG
    cat << EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}">
  <defs>
    <linearGradient id="barGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:${accent_color};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${purple_color};stop-opacity:1" />
    </linearGradient>
    <filter id="shadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.3"/>
    </filter>
  </defs>

  <!-- Background -->
  <rect width="${width}" height="${height}" fill="${bg_color}" rx="12"/>

  <!-- Header -->
  <text x="30" y="45" font-family="system-ui, -apple-system, sans-serif" font-size="24" font-weight="bold" fill="${text_color}">
    who-ran-what
  </text>
  <text x="30" y="70" font-family="system-ui, -apple-system, sans-serif" font-size="14" fill="${accent_color}">
    ${period} Stats
  </text>

  <!-- Total calls badge -->
  <rect x="430" y="25" width="140" height="50" fill="${card_color}" rx="8" filter="url(#shadow)"/>
  <text x="500" y="50" font-family="system-ui, -apple-system, sans-serif" font-size="12" fill="${text_color}" text-anchor="middle">Total Calls</text>
  <text x="500" y="68" font-family="system-ui, -apple-system, sans-serif" font-size="16" font-weight="bold" fill="${green_color}" text-anchor="middle">${total_calls:-0}</text>

  <!-- Agents Section -->
  <text x="30" y="110" font-family="system-ui, -apple-system, sans-serif" font-size="14" font-weight="600" fill="${purple_color}">Top Agents</text>
EOF

    # Generate agent bars
    local y_pos=130
    local max_agent_count=1

    # Get max count for scaling
    if [[ -n "$agents_data" ]]; then
        max_agent_count=$(echo "$agents_data" | head -1 | awk '{print $1}')
        [[ "$max_agent_count" -eq 0 ]] && max_agent_count=1
    fi

    local agent_index=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local count name bar_width
        count=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        bar_width=$((count * 200 / max_agent_count))
        [[ "$bar_width" -lt 10 ]] && bar_width=10

        cat << EOF
  <text x="30" y="$((y_pos + 12))" font-family="monospace" font-size="11" fill="${text_color}">${name}</text>
  <rect x="130" y="$((y_pos))" width="${bar_width}" height="16" fill="url(#barGradient)" rx="3"/>
  <text x="$((135 + bar_width))" y="$((y_pos + 12))" font-family="monospace" font-size="11" fill="${accent_color}">${count}</text>
EOF
        y_pos=$((y_pos + 24))
        agent_index=$((agent_index + 1))
        [[ $agent_index -ge 5 ]] && break
    done <<< "$agents_data"

    # If no agents data
    if [[ -z "$agents_data" ]]; then
        cat << EOF
  <text x="30" y="$((y_pos + 12))" font-family="system-ui, sans-serif" font-size="11" fill="#565f89">No agent data</text>
EOF
        y_pos=$((y_pos + 24))
    fi

    # Tools Section
    y_pos=$((y_pos + 20))
    cat << EOF
  <text x="30" y="${y_pos}" font-family="system-ui, -apple-system, sans-serif" font-size="14" font-weight="600" fill="${green_color}">Top Tools</text>
EOF
    y_pos=$((y_pos + 20))

    # Get max count for tools
    local max_tool_count=1
    if [[ -n "$tools_data" ]]; then
        max_tool_count=$(echo "$tools_data" | head -1 | awk '{print $1}')
        [[ "$max_tool_count" -eq 0 ]] && max_tool_count=1
    fi

    local tool_index=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local count name bar_width
        count=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        bar_width=$((count * 200 / max_tool_count))
        [[ "$bar_width" -lt 10 ]] && bar_width=10

        cat << EOF
  <text x="30" y="$((y_pos + 12))" font-family="monospace" font-size="11" fill="${text_color}">${name}</text>
  <rect x="130" y="$((y_pos))" width="${bar_width}" height="16" fill="${green_color}" rx="3" opacity="0.8"/>
  <text x="$((135 + bar_width))" y="$((y_pos + 12))" font-family="monospace" font-size="11" fill="${green_color}">${count}</text>
EOF
        y_pos=$((y_pos + 24))
        tool_index=$((tool_index + 1))
        [[ $tool_index -ge 5 ]] && break
    done <<< "$tools_data"

    # Footer
    cat << EOF

  <!-- Footer -->
  <text x="30" y="380" font-family="system-ui, -apple-system, sans-serif" font-size="10" fill="#565f89">
    github.com/mylee04/who-ran-what
  </text>
  <text x="570" y="380" font-family="system-ui, -apple-system, sans-serif" font-size="10" fill="#565f89" text-anchor="end">
    $(date +%Y-%m-%d)
  </text>
</svg>
EOF
}

# Handle share command
handle_share_command() {
    local period="${1:-week}"
    local output_file="${2:-}"

    echo "Generating share image..."

    local result
    result=$(generate_share_image "$period" "$output_file")

    echo ""
    echo "Share image created: $result"
    echo ""
    echo "You can:"
    echo "  - Open in browser to view"
    echo "  - Share on social media"
    echo "  - Convert to PNG: open $result"

    # Try to open on macOS (only if interactive terminal)
    if [[ "$(uname -s)" == "Darwin" ]] && [[ -t 0 ]]; then
        echo ""
        read -p "Open in browser? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            open "$result"
        fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo ""
        echo "Run 'open $result' to view in browser"
    fi
}
