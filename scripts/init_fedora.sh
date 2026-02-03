#!/bin/bash
set -e

echo "=== Fedora dotfiles init ==="

# Fish
if ! command -v fish &>/dev/null; then
    sudo dnf install -y fish
    echo "✓ Fish installed"
else
    echo "✓ Fish already installed"
fi

if [ "$(basename "$SHELL")" != "fish" ]; then
    sudo chsh -s "$(which fish)" "$USER"
    echo "✓ Fish set as default shell (relogin required)"
else
    echo "✓ Fish is default shell"
fi

# Starship
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "✓ Starship installed"
else
    echo "✓ Starship already installed"
fi

# Fisher + plugins
if ! fish -c "type -q fisher" &>/dev/null; then
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    echo "✓ Fisher installed"
else
    echo "✓ Fisher already installed"
fi

if [ -f "$HOME/.config/fish/fish_plugins" ]; then
    fish -c "fisher update"
    echo "✓ Fish plugins updated"
fi

echo "=== Done ==="
