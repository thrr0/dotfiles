#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

# Crear backup si el destino existe y no es symlink
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "${target}.bak"
    echo "Backed up: $target -> ${target}.bak"
  fi
}

# Crear symlink
link() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  ln -sf "$src" "$dst"
  echo "Linked: $dst"
}

# ~/.config entries
for dir in autostart btop cava fastfetch gtk-3.0 gtk-4.0 hypr Kvantum kitty \
           nwg-look qt6ct rofi starship wal waybar; do
  link "$DOTFILES/.config/$dir" "$CONFIG/$dir"
done

# Archivos sueltos en .config
link "$DOTFILES/.config/starship.toml"   "$CONFIG/starship.toml"
link "$DOTFILES/.config/hyprland.conf"   "$CONFIG/hyprland.conf"
link "$DOTFILES/.config/monitors.conf"   "$CONFIG/monitors.conf"
link "$DOTFILES/.config/workspaces.conf" "$CONFIG/workspaces.conf"

# Scripts
link "$DOTFILES/.config/scripts" "$CONFIG/scripts"

# Home
link "$DOTFILES/home/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES/home/.zprofile" "$HOME/.zprofile"

echo "Done."
