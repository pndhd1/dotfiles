#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IGNORE_DIRS="scripts .git"

cd "$DOTFILES_DIR"

for dir in */; do
    dir="${dir%/}"

    if echo "$IGNORE_DIRS" | grep -qw "$dir"; then
        continue
    fi

    echo "Stowing $dir..."
    stow --adopt "$dir"
done

echo "Done"
