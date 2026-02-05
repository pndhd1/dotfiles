---
name: commit
description: Analyze git diff and create commit message in project style
model: sonnet
argument-hint: [hint what to commit]
allowed-tools: Bash(git:*), AskUserQuestion
---

Analyze the git repository changes and create a commit following the project's commit style.

**User hint:** $ARGUMENTS

## Output format

**STRICT RULE:** Every text message you output MUST follow this structure. No free-form text.

```
### <Step title>

<content>
```

## Steps

1. **Get all changes:**
   - Run `git diff HEAD` to see all changes (staged and unstaged)
   - Run `git diff HEAD --name-only` to get list of changed files
   - Run `git status` to see untracked files

2. **Analyze and group changes by functionality:**
   - Review the diff content
   - Group changes into logical units (e.g., "authentication", "logging", "UI refactoring", "bug fixes", "config changes")
   - Note which files belong to each functionality group

3. **Review diff for potential issues:**
   - Scan the diff for things that likely should NOT be committed:
     * Debug logging
     * Debug markers (`TODO`, `FIXME`, `HACK`, `XXX`, `TEMP`)
     * Commented-out code blocks
     * Hardcoded credentials, tokens, secrets
     * Leftover merge conflict markers (`<<<<<<<`, `>>>>>>>`)
     * Obvious typos in variable names, function names, comments, or strings
   - If issues found — output them BEFORE proceeding. Example:

     ```
     ### Potential issues

     - `src/auth.ts:42` — `console.log("debug user", user)` looks like debug logging
     - `src/utils.ts:15` — typo in variable name: `conifg` → `config`
     - `src/api.ts:88` — `// TODO: remove this hack` marker
     ```

   - If no issues found — skip this output, proceed silently

4. **Determine what to commit:**
   - If user provided a hint ($ARGUMENTS) — use it to select the appropriate functionality
   - If no hint or hint is unclear — output the groups and ask:

     ```
     ### Changes found

     - **auth**: Add login validation (`src/auth.ts`, `src/middleware.ts`)
     - **ui**: Update button styles (`src/components/Button.tsx`)
     - **config**: Add Redis connection settings (`config/redis.yml`)
     ```

     Then use AskUserQuestion:
     - First option: "All changes"
     - Other options: each identified functionality group (with brief description)
   - Do NOT mention "staged" or "unstaged" — just refer to "changes"

5. **Stage selected changes:**
   - If "All changes" — run `git add -A`
   - If specific functionality — run `git add <files>` only for files in that group

6. **Analyze project commit style:**
   - Run `git log --oneline -20` to see recent commits
   - Identify the commit message pattern:
     * Conventional commits (feat:, fix:, etc.)
     * Task/issue numbers (e.g., [TASK-123], #123, PROJ-456)
     * Custom prefixes or formats
   - If task numbers are present in history, ask user for task number

7. **Generate and present commit message:**
   - Create commit message matching the project's style
   - **CRITICAL:** First, output the message as a separate text block:

     ```
     ### Commit message

     ```
     <commit message here>
     ```

     <1-2 sentence explanation of what this commit does>
     ```

   - **THEN** call AskUserQuestion with options:
     - "Commit" — proceed with this message
     - "Edit message" — user wants to modify
   - NEVER put the commit message inside AskUserQuestion options or descriptions
   - If "Commit" — execute `git commit` using HEREDOC format:
     ```
     git commit -m "$(cat <<'EOF'
     <message>
     EOF
     )"
     ```
   - If "Edit message" — ask user for the new message, then commit

## Rules

- **Adapt to project style** — don't force conventional commits if project uses different format
- Message language: match project history (usually English)
- Subject max 72 characters (unless project uses longer)
- Use imperative mood ("add" not "added")
- Be specific and informative
- Never use "staged/unstaged" terminology with user — just "changes"

## Full output example

Here is an example of what a complete session looks like. Follow this format exactly.

---

**Model output (text):**

```
### Potential issues

- `src/api.ts:23` — `console.log("response", data)` looks like debug logging
- `src/helpers.ts:7` — typo: `fucntion` → `function`
```

**Model calls AskUserQuestion:** "Proceed despite issues?"
- "Yes, commit as is"
- "Let me fix first"

*(user selects "Yes, commit as is")*

**Model output (text):**

```
### Changes found

- **api**: Add retry logic for failed requests (`src/api.ts`, `src/api.test.ts`)
- **config**: Increase timeout to 30s (`config/app.yml`)
```

**Model calls AskUserQuestion:** "What to commit?"
- "All changes"
- "api: retry logic"
- "config: timeout"

*(user selects "All changes")*

**Model output (text):**

```
### Commit message

```
feat(api): add retry logic for failed HTTP requests
```

Adds automatic retry with exponential backoff for transient HTTP errors (5xx, timeout). Default: 3 attempts.
```

**Model calls AskUserQuestion:** "Confirm commit?"
- "Commit"
- "Edit message"

*(user selects "Commit")*

**Model executes:** `git commit -m "..."`

---

## Style adaptation examples

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
