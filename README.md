# who-ran-what

> **Track your AI agent and skill usage** - See what ran, when, and how often.

Analytics dashboard for AI coding tools - track agent invocations, skill usage, and optimize your workflow.

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/mylee04/who-ran-what/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Agent tracking** - See which agents you use most (Sisyphus, Oracle, Librarian, etc.)
- **Skill analytics** - Track skill/MCP usage frequency
- **Time views** - Daily, weekly, monthly breakdowns
- **Project insights** - Usage patterns per project
- **Cleanup suggestions** - Identify unused agents/skills

## Installation

```bash
brew tap mylee04/tools
brew install who-ran-what
```

## Usage

```bash
wr                # Dashboard (default)
wr today          # Today's usage
wr week           # Weekly view
wr month          # Monthly view
wr agents         # Agent breakdown
wr skills         # Skill breakdown
wrp               # Current project stats
```

## Example Output

```
┌─────────────────────────────────────────────────────┐
│  who-ran-what              Today | Week | Month     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📊 Top Agents (This Week)                          │
│  ├── Sisyphus      ████████████████  847 calls      │
│  ├── Oracle        ████████          412 calls      │
│  ├── Librarian     ██████            298 calls      │
│  └── Explore       ████              201 calls      │
│                                                     │
│  🔧 Top Skills                                      │
│  ├── git-master    ████████████      523 uses       │
│  ├── playwright    ██████            287 uses       │
│  └── web-search    ████              178 uses       │
│                                                     │
│  ⚠️  Unused (30+ days)                              │
│  └── deprecated-skill, old-mcp     → Remove?        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Data Sources

| Tool | Location |
|------|----------|
| Claude Code | `~/.claude/projects/` |
| OpenCode | `~/.local/share/opencode/` |
| Codex CLI | `~/.codex/sessions/` |
| Gemini CLI | `~/.gemini/` |

## Links

- [GitHub Issues](https://github.com/mylee04/who-ran-what/issues)

## License

MIT License - see [LICENSE](LICENSE)
