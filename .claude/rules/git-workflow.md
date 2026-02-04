# Git Workflow Rules

## Branch Strategy

- `main` - Production-ready code
- Feature branches for development

## Commit Message Format

```
type: brief description

- Detail 1
- Detail 2
```

### Types

| Type     | Description           |
| -------- | --------------------- |
| feat     | New feature           |
| fix      | Bug fix               |
| docs     | Documentation only    |
| refactor | Code refactoring      |
| test     | Adding/updating tests |
| chore    | Maintenance tasks     |

### Examples

```
feat: add Gemini CLI parser

- Parse ~/.gemini/sessions/ for tool usage
- Support date filtering
- Match Claude parser interface
```

```
fix: handle missing session files gracefully

- Check file existence before parsing
- Log warning instead of error
```

## Pre-Commit Checklist

- [ ] `make test` passes
- [ ] No shellcheck warnings
- [ ] No hardcoded credentials
- [ ] Meaningful commit message
- [ ] No .env files staged

## Rules

- Never force push to main
- Never commit credentials
- No Co-Authored-By lines
- Run tests before pushing
- Keep commits focused and atomic

## Never Commit

- `.env`
- `*.pem`, `*.key`
- `credentials.json`
- IDE settings (unless shared)
