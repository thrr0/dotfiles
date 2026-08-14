#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

# Create backup if destination exists and is not a symlink
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "${target}.bak"
    echo "Backed up: $target -> ${target}.bak"
  fi
}

# Create symlink
link() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  ln -sfn "$src" "$dst"
  echo "Linked: $dst"
}

# ~/.config entries
for dir in btop cava dunst fastfetch gtk-3.0 gtk-4.0 hypr Kvantum kitty \
           nwg-look qt6ct quickshell rofi wal waybar wlogout; do
  link "$DOTFILES/.config/$dir" "$CONFIG/$dir"
done

# Standalone files in .config
link "$DOTFILES/.config/starship.toml"   "$CONFIG/starship.toml"

# Scripts
link "$DOTFILES/.config/scripts" "$CONFIG/scripts"

# Home
link "$DOTFILES/home/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES/home/.zprofile" "$HOME/.zprofile"

echo "Done."
