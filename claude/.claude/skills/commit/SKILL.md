---
name: commit
description: Analyze git diff and create commit message in project style
model: sonnet
argument-hint: [hint what to commit]
allowed-tools: Bash(git:*), AskUserQuestion
---

Analyze the git repository changes and create a commit following the project's commit style.

**User hint:** $ARGUMENTS

Steps:

1. **Get all changes:**
   - Run `git diff HEAD` to see all changes (staged and unstaged)
   - Run `git diff HEAD --name-only` to get list of changed files
   - Run `git status` to see untracked files

2. **Analyze and group changes by functionality:**
   - Review the diff content
   - Group changes into logical units (e.g., "authentication", "logging", "UI refactoring", "bug fixes", "config changes")
   - Note which files belong to each functionality group

3. **Determine what to commit:**
   - If user provided a hint ($ARGUMENTS) — use it to select the appropriate functionality
   - If no hint or hint is unclear — ask the user using AskUserQuestion:
     - First option: "All changes"
     - Other options: each identified functionality group (with brief description)
   - Do NOT mention "staged" or "unstaged" — just refer to "changes"

4. **Stage selected changes:**
   - If "All changes" — run `git add -A`
   - If specific functionality — run `git add <files>` only for files in that group

5. **Analyze project commit style:**
   - Run `git log --oneline -20` to see recent commits
   - Identify the commit message pattern:
     * Conventional commits (feat:, fix:, etc.)
     * Task/issue numbers (e.g., [TASK-123], #123, PROJ-456)
     * Custom prefixes or formats
   - If task numbers are present in history, ask user for task number

6. **Generate and confirm commit:**
   - Create commit message matching the project's style
   - Use AskUserQuestion to ask for confirmation with options:
     - "Yes" - create commit with this message
     - "Edit message" - user wants to modify the message
   - If "Yes" selected, execute `git commit -m "<message>"`
   - If "Edit message", ask user to provide the new message and then commit

Rules:
- **Adapt to project style** - don't force conventional commits if project uses different format
- Message language: match project history (usually English)
- Subject max 72 characters (unless project uses longer)
- Use imperative mood ("add" not "added")
- Be specific and informative
- Never use "staged/unstaged" terminology with user — just "changes"

Style adaptation examples:

**Conventional commits:**
```
feat(auth): add biometric authentication support
```

**With task numbers:**
```
[TASK-456] Add biometric authentication support
```

**Simple descriptive:**
```
Add biometric authentication to login screen
```

**Jira style:**
```
PROJ-123: Implement biometric authentication
```
