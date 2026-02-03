# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles repository for Fedora. Scripts go in `scripts/` directory.

## Writing Scripts

- Ask user where to place the script:
  - `scripts/` — init/setup scripts (not in PATH)
  - `bin/.local/bin/` — CLI tools (symlinked to ~/.local/bin, in PATH)
- Use bash with `set -e`
- Make executable: `chmod +x scripts/<name>.sh`
- Scripts may run via symlinks, always resolve real path:
  ```bash
  SCRIPT_PATH="$(readlink -f "$0")"
  ```
