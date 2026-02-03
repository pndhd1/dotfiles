#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_NAME="dotfiles-update"

notify() {
    local urgency="$1"
    local title="$2"
    local message="$3"

    if command -v notify-send &>/dev/null; then
        notify-send --urgency="$urgency" "$title" "$message"
    fi

    echo "[$urgency] $title: $message"
}

cd "$DOTFILES_DIR"

# Fetch remote changes
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
BASE=$(git merge-base HEAD @{u} 2>/dev/null || echo "")

if [ -z "$REMOTE" ]; then
    notify "low" "$SCRIPT_NAME" "No upstream branch configured"
    exit 0
fi

if [ "$LOCAL" = "$REMOTE" ]; then
    notify "low" "$SCRIPT_NAME" "Already up to date"
    exit 0
fi

if [ "$LOCAL" = "$BASE" ]; then
    # Local is behind, safe to pull
    if git pull --ff-only origin 2>/dev/null; then
        notify "normal" "$SCRIPT_NAME" "Updated successfully"

        # Re-apply stow after update
        if [ -x "$DOTFILES_DIR/scripts/stow_all.sh" ]; then
            "$DOTFILES_DIR/scripts/stow_all.sh"
        fi
    else
        notify "critical" "$SCRIPT_NAME" "Fast-forward failed. Manual intervention required."
        exit 1
    fi
elif [ "$REMOTE" = "$BASE" ]; then
    # Local is ahead
    notify "normal" "$SCRIPT_NAME" "Local changes not pushed"
else
    # Diverged - merge with local preference
    notify "normal" "$SCRIPT_NAME" "Conflict detected. Merging with local preference..."

    if git merge -X ours origin/$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | sed 's|origin/||'); then
        notify "normal" "$SCRIPT_NAME" "Merged with local changes preserved"

        # Re-apply stow after merge
        if [ -x "$DOTFILES_DIR/scripts/stow_all.sh" ]; then
            "$DOTFILES_DIR/scripts/stow_all.sh"
        fi
    else
        notify "critical" "$SCRIPT_NAME" "Merge failed. Manual intervention required."
        exit 1
    fi
fi
