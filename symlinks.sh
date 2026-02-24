#!/bin/bash

# Ensure stow is installed
if ! command -v stow &>/dev/null; then
    echo "stow not found, installing..."
    sudo pacman -S --noconfirm stow
fi

# Ensure .config directory exists
mkdir -p ~/.config

# Create symlinks using stow
stow -t ~ tmux
stow -t ~ fish
stow -t ~ nvim
stow -t ~ alacritty
stow -t ~ hypr
stow -t ~ pypoetry
