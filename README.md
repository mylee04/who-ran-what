# who-ran-what

> **Track your AI agent and skill usage** - See what ran, when, and how often.

Analytics dashboard for AI coding tools - track agent invocations, skill usage, and optimize your workflow.

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/mylee04/who-ran-what/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)]()

## Features

- **Agent tracking** - See which agents you use most (Explore, Plan, code-reviewer, etc.)
- **Skill analytics** - Track skill/MCP usage frequency
- **Time views** - Daily, weekly, monthly breakdowns
- **Project insights** - Usage patterns per project
- **Cleanup suggestions** - Identify unused agents/skills

## Requirements

- **Bash** 3.2 or later
- **jq** (recommended for better JSON parsing)
- **Claude Code** installed with session data in `~/.claude/`

## Installation

### macOS

**Option 1: Homebrew (Recommended)**

```bash
brew tap mylee04/tools
brew install who-ran-what
```

**Option 2: Manual Install**

```bash
# Clone the repository
git clone https://github.com/mylee04/who-ran-what.git
cd who-ran-what

# Add to your PATH (add this to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:$(pwd)/bin"

# Or create a symlink
ln -s "$(pwd)/bin/who-ran-what" /usr/local/bin/wr
```

**Install jq (optional but recommended)**

```bash
brew install jq
```

### Linux

```bash
# Clone the repository
git clone https://github.com/mylee04/who-ran-what.git
cd who-ran-what

# Add to your PATH (add this to ~/.bashrc)
export PATH="$PATH:$(pwd)/bin"

# Or install system-wide
sudo ln -s "$(pwd)/bin/who-ran-what" /usr/local/bin/wr

# Install jq (optional but recommended)
# Ubuntu/Debian
sudo apt install jq

# Fedora
sudo dnf install jq
```

### Windows

**Option 1: Git Bash (Recommended)**

1. Install [Git for Windows](https://git-scm.com/download/win) (includes Git Bash)
2. Open Git Bash and run:

```bash
# Clone the repository
git clone https://github.com/mylee04/who-ran-what.git
cd who-ran-what

# Add to your PATH
echo 'export PATH="$PATH:'$(pwd)'/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Option 2: WSL (Windows Subsystem for Linux)**

1. Install WSL: Open PowerShell as Admin and run:
   ```powershell
   wsl --install
   ```

2. Open Ubuntu (or your WSL distro) and follow the Linux instructions above.

**Option 3: Cygwin**

1. Install [Cygwin](https://www.cygwin.com/) with `bash`, `git`, and `jq` packages
2. Open Cygwin terminal and follow the Linux instructions

**Install jq on Windows**

```bash
# Git Bash - download manually
curl -L -o /usr/bin/jq.exe https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe

# WSL (Ubuntu)
sudo apt install jq

# Or use winget (PowerShell)
winget install jqlang.jq
```

## Quick Start

After installation, verify it works:

```bash
# Check version
wr version

# Show help
wr help

# View your dashboard
wr
```

## Usage

### Main Commands

| Command | Description |
|---------|-------------|
| `wr` | Dashboard overview (default: weekly view) |
| `wr today` | Today's usage stats |
| `wr week` | This week's breakdown |
| `wr month` | This month's breakdown |
| `wr agents` | All-time agent statistics |
| `wr skills` | All-time skill statistics |
| `wr projects` | Project breakdown |
| `wr clean` | Show unused agents/skills (30+ days) |
| `wr help` | Show help message |
| `wr version` | Show version |

### Project Commands

| Command | Description |
|---------|-------------|
| `wrp` | Current project stats |
| `wrp agents` | Current project's agent usage |
| `wrp skills` | Current project's skill usage |

### Examples

```bash
# See what you used today
wr today

# Check which agents you use most
wr agents

# Find unused skills to clean up
wr clean

# Check current project stats
wrp
```

## Example Output

```
who-ran-what                    week
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Top Agents (This Week)
  ├── Explore      ████████████████████  847 calls
  ├── Plan         ██████████░░░░░░░░░░  412 calls
  ├── code-reviewer ██████░░░░░░░░░░░░░░  298 calls
  └── test-engineer ████░░░░░░░░░░░░░░░░  201 calls

🔧 Top Skills
  ├── commit       ████████████████████  523 uses
  ├── review       ██████████░░░░░░░░░░  287 uses
  └── validate     ██████░░░░░░░░░░░░░░  178 uses

🛠️  Top Tools
  ├── Bash         ████████████████████  3842 uses
  ├── Read         ██████████████████░░  3156 uses
  ├── Edit         ██████░░░░░░░░░░░░░░  892 uses
  ├── Grep         ████░░░░░░░░░░░░░░░░  534 uses
  └── Write        ██░░░░░░░░░░░░░░░░░░  267 uses

📁 Projects with Claude Data
  ├── my-webapp            42 sessions
  ├── api-server           28 sessions
  ├── mobile-app           15 sessions

⚠️  Unused (30+ days)
  └── old-legacy-skill     → Remove?
```

## Data Sources

Currently supported:

| Tool | Data Location | Status |
|------|---------------|--------|
| Claude Code | `~/.claude/projects/` | Fully supported |
| OpenCode | `~/.local/share/opencode/` | Coming soon |
| Codex CLI | `~/.codex/sessions/` | Coming soon |
| Gemini CLI | `~/.gemini/` | Coming soon |

## Troubleshooting

### "command not found: wr"

Make sure the bin directory is in your PATH:

```bash
# Check if it's in PATH
echo $PATH | grep who-ran-what

# Add it manually
export PATH="$PATH:/path/to/who-ran-what/bin"
```

### "No session data found"

Make sure you have Claude Code installed and have used it at least once:

```bash
# Check if Claude data exists
ls ~/.claude/projects/
```

### Colors not showing (Windows)

Git Bash and WSL support colors by default. If using CMD or PowerShell directly, colors may not display correctly. Use Git Bash or WSL for the best experience.

### jq not found (warning)

The tool works without jq but parsing is more accurate with it:

```bash
# macOS
brew install jq

# Linux
sudo apt install jq

# Windows (Git Bash)
curl -L -o /usr/bin/jq.exe https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe
```

## Uninstall

**Homebrew**
```bash
brew uninstall who-ran-what
brew untap mylee04/tools
```

**Manual**
```bash
# Remove the directory
rm -rf /path/to/who-ran-what

# Remove from PATH (edit ~/.bashrc or ~/.zshrc)
# Remove the line: export PATH="$PATH:/path/to/who-ran-what/bin"
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Links

- [GitHub Repository](https://github.com/mylee04/who-ran-what)
- [Issues & Bug Reports](https://github.com/mylee04/who-ran-what/issues)
- [Releases](https://github.com/mylee04/who-ran-what/releases)

## License

MIT License - see [LICENSE](LICENSE) for details.
