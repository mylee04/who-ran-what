# who-ran-what Project Guidelines

## Project Overview
Shell-based CLI tool for tracking AI coding assistant usage (Claude, Gemini, Codex, OpenCode).

## Custom Agent Usage

When working on this project, use these specialized agents:

| Situation | Agent | Why |
|-----------|-------|-----|
| Reviewing shell scripts | `code-reviewer` | Shell-specific security & best practices |
| Testing on macOS vs Linux | `cross-platform-auditor` | Date commands, bash versions differ |
| Testing shell edge cases | `shell-tester` | Input validation, error handling |
| Improving CLI UX | `cli-ux-designer` | Help text, output formatting |

## Skill Usage (Slash Commands)

**Use these skills proactively:**

- `/validate` - Run BEFORE committing any changes
- `/review` - Run when code review is requested
- `/test` - Run after implementing features
- `/stats` - Check usage statistics

## Code Standards

- All variables must be quoted: `"$var"`
- Functions must use `local` for variables
- Use `[[ ]]` not `[ ]` for conditionals
- Use `command -v` not `which`
- Always run `shellcheck` before committing

## File Structure

```
bin/           - Main executable
lib/           - Library functions (parsers, display, etc.)
tests/         - Test scripts
```

## Testing

Always run before committing:
```bash
./tests/run_all.sh
shellcheck bin/who-ran-what lib/who-ran-what/**/*.sh
```
