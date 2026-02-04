---
description: Run demo commands to showcase who-ran-what features
---

# Demo Mode

## What This Command Does

Runs through all main features to demonstrate the tool's capabilities.

## Demo Script

### 1. Show Version and Help

```bash
echo "=== who-ran-what Demo ==="
echo ""

echo "1. Version"
./bin/who-ran-what version
echo ""

echo "2. Help"
./bin/who-ran-what help
echo ""
```

### 2. Dashboard Views

```bash
echo "3. Weekly Dashboard (default)"
./bin/who-ran-what
echo ""

echo "4. Today's Activity"
./bin/who-ran-what today
echo ""

echo "5. Monthly Overview"
./bin/who-ran-what month
echo ""
```

### 3. Detailed Stats

```bash
echo "6. Agent Statistics"
./bin/who-ran-what agents
echo ""

echo "7. Skill Usage"
./bin/who-ran-what skills
echo ""

echo "8. Project Breakdown"
./bin/who-ran-what projects
echo ""
```

### 4. Cleanup Suggestions

```bash
echo "9. Unused Items (cleanup suggestions)"
./bin/who-ran-what clean
echo ""
```

### 5. Project-Specific Commands

```bash
echo "10. Current Project Status"
./bin/who-ran-what project
echo ""
```

## Usage

Run this demo to see all features in action. Useful for:

- Learning what the tool can do
- Testing after changes
- Showing the tool to others
