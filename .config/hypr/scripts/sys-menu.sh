#!/bin/bash
# sys-menu.sh — system utilities hub

ROFI="rofi -dmenu -i"
THEME="-theme $HOME/.config/rofi/sys-menu.rasi"
TERM="kitty"
EDITOR="nvim"
AUR="yay"

# ─── helpers ────────────────────────────────────────────────────────────────

confirm() {
    [[ "$(printf 'Yes\nNo' | $ROFI $THEME -p "$1")" == "Yes" ]]
}

open_editor() {
    $TERM -e $EDITOR "$1"
}

run_term() {
    $TERM --hold -e bash -c "$*"
}

rofi_wide() {
    rofi -dmenu -i \
        -theme "$HOME/.config/rofi/sys-menu.rasi" \
        -theme-str 'window { width: 720px; }'
}

# ─── packages ───────────────────────────────────────────────────────────────

pkg_browse() {
    local list chosen pkg info action

    list=$(pacman -Ss . 2>/dev/null | paste - - | awk -F'\t' '{
        split($1, p, " "); split(p[1], a, "/")
        repo = a[1]; name = a[2]; ver = p[2]
        inst = ($1 ~ /\[installed/) ? "✓" : " "
        desc = $2; gsub(/^[ \t]+/, "", desc)
        printf "[%s] %-30s %-16s %s  %s\n", repo, name, ver, inst, desc
    }')

    chosen=$(echo "$list" | rofi_wide -p "󰏔  browse") || return
    pkg=$(echo "$chosen" | awk '{print $2}')
    [[ -z "$pkg" ]] && return

    info=$(yay -Si "$pkg" 2>/dev/null \
        | grep -E '^(Name|Version|Description|Installed Size|URL)' \
        | sed 's/  \+/ /g')

    if pacman -Qi "$pkg" &>/dev/null; then
        action=$(printf 'Remove\nCancel' \
            | $ROFI $THEME -p "󰆴 $pkg" -mesg "$info")
        [[ "$action" == "Remove" ]] && confirm "Remove $pkg?" \
            && run_term "$AUR -Rns $pkg"
    else
        action=$(printf 'Install\nCancel' \
            | $ROFI $THEME -p "󰏔 $pkg" -mesg "$info")
        [[ "$action" == "Install" ]] && run_term "$AUR -S $pkg"
    fi
}

pkg_search_aur() {
    local query list chosen pkg info action

    query=$(printf '' | $ROFI $THEME -p "󰍉  search aur") || return
    [[ -z "$query" ]] && return

    list=$(yay -Ss "$query" --aur 2>/dev/null | paste - - | awk -F'\t' '{
        split($1, p, " "); split(p[1], a, "/")
        name = a[2]; ver = p[2]
        inst = ($1 ~ /\[installed/) ? "✓" : " "
        desc = $2; gsub(/^[ \t]+/, "", desc)
        printf "[aur] %-30s %-16s %s  %s\n", name, ver, inst, desc
    }')

    if [[ -z "$list" ]]; then
        notify-send "AUR" "No results for '$query'"
        return
    fi

    chosen=$(echo "$list" | rofi_wide -p "󰏔 $query") || return
    pkg=$(echo "$chosen" | awk '{print $2}')
    [[ -z "$pkg" ]] && return

    info=$(yay -Si "$pkg" 2>/dev/null \
        | grep -E '^(Name|Version|Description|Installed Size|URL)' \
        | sed 's/  \+/ /g')

    if pacman -Qi "$pkg" &>/dev/null; then
        action=$(printf 'Remove\nCancel' \
            | $ROFI $THEME -p "󰆴 $pkg" -mesg "$info")
        [[ "$action" == "Remove" ]] && confirm "Remove $pkg?" \
            && run_term "$AUR -Rns $pkg"
    else
        action=$(printf 'Install\nCancel' \
            | $ROFI $THEME -p "󰏔 $pkg" -mesg "$info")
        [[ "$action" == "Install" ]] && run_term "$AUR -S $pkg"
    fi
}

pkg_remove() {
    local chosen info action

    chosen=$(pacman -Qq | $ROFI $THEME -p "󰆴  remove") || return
    [[ -z "$chosen" ]] && return

    info=$(yay -Qi "$chosen" 2>/dev/null \
        | grep -E '^(Name|Version|Description|Installed Size|Depends On)' \
        | sed 's/  \+/ /g')

    action=$(printf 'Remove\nCancel' \
        | $ROFI $THEME -p "󰆴 $chosen" -mesg "$info")
    [[ "$action" == "Remove" ]] && confirm "Remove $chosen?" \
        && run_term "$AUR -Rns $chosen"
}

pkg_orphans() {
    local orphans count

    orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -z "$orphans" ]]; then
        notify-send "Packages" "No orphans found"
        return
    fi

    count=$(echo "$orphans" | wc -l)
    confirm "Remove $count orphan(s)?" \
        && run_term "yay -Rns \$(pacman -Qtdq)"
}

menu_packages() {
    while true; do
        local chosen
        chosen=$(printf '%s\n' \
            "󰁍  Back" \
            "󰏔  Browse & Install" \
            "󰍉  Search AUR" \
            "󰆴  Remove" \
            "󰚰  Update system" \
            "󰁼  Clean orphans" \
            | $ROFI $THEME -p "󰏔  packages") || return

        case "$chosen" in
            *"Back"*)    return ;;
            *"Browse"*)  pkg_browse ;;
            *"AUR"*)     pkg_search_aur ;;
            *"Remove"*)  pkg_remove ;;
            *"Update"*)  run_term "$AUR -Syu" ;;
            *"orphans"*) pkg_orphans ;;
        esac
    done
}

# ─── monitoring ─────────────────────────────────────────────────────────────

kill_proc() {
    local list chosen pid name

    list=$(ps aux --sort=-%cpu | awk 'NR>1 {
        printf "%-10s %6s  %5s%%  %s\n", $1, $2, $3, $11
    }' | head -60)

    chosen=$(echo "$list" | rofi_wide -p "󱎴  kill process") || return
    pid=$(echo "$chosen" | awk '{print $2}')
    name=$(echo "$chosen" | awk '{print $4}')
    [[ -z "$pid" ]] && return

    confirm "Kill $name (PID $pid)?" \
        && kill "$pid" \
        && notify-send "Killed" "$name (PID $pid)"
}

view_logs() {
    local chosen

    chosen=$(systemctl list-units --type=service --state=running --no-legend --no-pager \
        | awk '{print $1}' \
        | $ROFI $THEME -p "󱂅  logs") || return
    [[ -z "$chosen" ]] && return

    $TERM -e journalctl -fu "$chosen"
}

menu_monitoring() {
    while true; do
        local chosen
        chosen=$(printf '%s\n' \
            "󰁍  Back" \
            "󰊖  btop" \
            "󱎴  Kill process" \
            "󱂅  Logs" \
            | $ROFI $THEME -p "󰻠  monitoring") || return

        case "$chosen" in
            *"Back"*)  return ;;
            *"btop"*)  $TERM --title btop -e btop ;;
            *"Kill"*)  kill_proc ;;
            *"Logs"*)  view_logs ;;
        esac
    done
}

# ─── config ─────────────────────────────────────────────────────────────────

menu_config() {
    while true; do
        local chosen
        chosen=$(printf '%s\n' \
            "󰁍  Back" \
            "󰒓  hyprland.conf" \
            "󱂬  waybar config" \
            "󰏘  waybar style.css" \
            "󰄛  kitty.conf" \
            "󰆓  .zshrc" \
            "  nvim" \
            "󰂚  dunst" \
            "󰑓  Reload waybar" \
            | $ROFI $THEME -p "󰒓  config") || return

        case "$chosen" in
            *"Back"*)         return ;;
            *"hyprland"*)     open_editor "$HOME/.config/hypr/hyprland.conf" ;;
            *"waybar config"*) open_editor "$HOME/.config/waybar/config" ;;
            *"waybar style"*)  open_editor "$HOME/.config/waybar/style.css" ;;
            *"kitty"*)        open_editor "$HOME/.config/kitty/kitty.conf" ;;
            *"zshrc"*)        open_editor "$HOME/.zshrc" ;;
            *"nvim"*)         open_editor "$HOME/.config/nvim/" ;;
            *"dunst"*)        open_editor "$HOME/.config/dunst/dunstrc" ;;
            *"Reload"*)       pkill waybar && waybar & ;;
        esac
    done
}

# ─── system ─────────────────────────────────────────────────────────────────

menu_system() {
    while true; do
        local chosen
        chosen=$(printf '%s\n' \
            "󰁍  Back" \
            "󰌾  Lock" \
            "󰒲  Suspend" \
            "󰜉  Reboot" \
            "󰐥  Shutdown" \
            | $ROFI $THEME -p "󰐥  system") || return

        case "$chosen" in
            *"Back"*)     return ;;
            *"Lock"*)     hyprlock ;;
            *"Suspend"*)  confirm "Suspend?"  && systemctl suspend ;;
            *"Reboot"*)   confirm "Reboot?"   && systemctl reboot ;;
            *"Shutdown"*) confirm "Shutdown?" && systemctl poweroff ;;
        esac
    done
}

# ─── utilities ──────────────────────────────────────────────────────────────

audio_switch() {
    local sinks chosen sink_id

    sinks=$(pactl list sinks | awk '
        /^Sink #/         { id = substr($2, 2) }
        /^\tDescription:/ { desc = substr($0, index($0, $2)); print id "\t" desc }
    ')

    if [[ -z "$sinks" ]]; then
        notify-send "Audio" "No output devices found"
        return
    fi

    chosen=$(echo "$sinks" | awk -F'\t' '{print $2}' \
        | $ROFI $THEME -p "󰕾  audio output") || return
    [[ -z "$chosen" ]] && return

    sink_id=$(echo "$sinks" | awk -F'\t' -v n="$chosen" '$2 == n { print $1; exit }')
    pactl set-default-sink "$sink_id"
    notify-send "Audio" "→ $chosen"
}

services_menu() {
    local units chosen unit info action

    units=$(systemctl --user list-units --type=service --no-legend --no-pager | awk '{
        icon = ($3 == "running") ? "▶" : "■"
        printf "%s  %-42s [%s]\n", icon, $1, $3
    }')

    if [[ -z "$units" ]]; then
        notify-send "Services" "No user services found"
        return
    fi

    chosen=$(echo "$units" | rofi_wide -p "󰒔  services") || return
    unit=$(echo "$chosen" | awk '{print $2}')
    [[ -z "$unit" ]] && return

    info=$(systemctl --user status "$unit" --no-pager -l 2>&1 | head -12)

    action=$(printf 'Start\nStop\nRestart\nCancel' \
        | $ROFI $THEME -p "󰒔 $unit" -mesg "$info") || return

    case "$action" in
        Start)   systemctl --user start   "$unit" && notify-send "Services" "Started $unit" ;;
        Stop)    systemctl --user stop    "$unit" && notify-send "Services" "Stopped $unit" ;;
        Restart) systemctl --user restart "$unit" && notify-send "Services" "Restarted $unit" ;;
    esac
}

pywal_menu() {
    local action
    action=$(printf '󰑓  Regenerate colors\n󰸉  Choose new wallpaper\n  Cancel' \
        | $ROFI $THEME -p "󰏘  pywal") || return

    case "$action" in
        *"Regenerate"*) wal -R && notify-send "Pywal" "Colors regenerated" ;;
        *"Choose"*)     ~/.config/hypr/scripts/wallpaper.sh ;;
    esac
}

screenshot_menu() {
    local chosen out

    chosen=$(printf '󰆟  Area → clipboard\n󰹑  Area → file\n󰹑  Screen → file' \
        | $ROFI $THEME -p "󰹑  screenshot") || return

    mkdir -p ~/pictures/screenshots
    out=~/pictures/screenshots/$(date +%Y%m%d_%H%M%S).png

    case "$chosen" in
        *clipboard*) grim -g "$(slurp)" - | wl-copy ;;
        *Area*)      grim -g "$(slurp)" "$out" ;;
        *Screen*)    grim "$out" ;;
    esac
}

menu_utilities() {
    while true; do
        local chosen
        chosen=$(printf '%s\n' \
            "󰁍  Back" \
            "󰸉  Wallpaper" \
            "󰅍  Clipboard" \
            "󰹑  Screenshot" \
            "󰛳  Network" \
            "󰕾  Audio output" \
            "󰒔  Services" \
            "󰏘  Pywal" \
            | $ROFI $THEME -p "󰧮  utilities") || return

        case "$chosen" in
            *"Back"*)       return ;;
            *"Wallpaper"*)  ~/.config/hypr/scripts/wallpaper.sh ;;
            *"Clipboard"*)  cliphist list | $ROFI $THEME -p "󰅍  clipboard" \
                                | cliphist decode | wl-copy ;;
            *"Screenshot"*) screenshot_menu ;;
            *"Network"*)    $TERM -e nmtui ;;
            *"Audio"*)      audio_switch ;;
            *"Services"*)   services_menu ;;
            *"Pywal"*)      pywal_menu ;;
        esac
    done
}

# ─── main loop ──────────────────────────────────────────────────────────────

while true; do
    chosen=$(printf '%s\n' \
        "󰏔  Packages" \
        "󰻠  Monitoring" \
        "󰒓  Config" \
        "󰐥  System" \
        "󰧮  Utilities" \
        | $ROFI $THEME -p "  system") || exit 0

    case "$chosen" in
        *"Packages"*)   menu_packages ;;
        *"Monitoring"*) menu_monitoring ;;
        *"Config"*)     menu_config ;;
        *"System"*)     menu_system ;;
        *"Utilities"*)  menu_utilities ;;
    esac
done
