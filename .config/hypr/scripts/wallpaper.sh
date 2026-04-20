#!/bin/bash

WALLPAPER_DIR="$HOME/.config/wallpapers"

if [ -n "$1" ]; then
  WALLPAPER=$1
else
  WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) | \
    rofi -dmenu -p "Wallpaper" -i)
fi

[ -z "$WALLPAPER" ] && exit 0

wal -i "$WALLPAPER"


cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

pkill dunst && dunst &

awww img "$WALLPAPER" --transition-type any --transition-duration 0.5 --transition-fps 144

pkill waybar && waybar &

oomox-cli ~/.cache/wal/colors-oomox -o wal-theme

gsettings set org.gnome.desktop.interface gtk-theme "wal-theme"
