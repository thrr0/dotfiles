# Created by newuser for 5.9
## Aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias vi='nvim'
alias rc='nvim ~/.zshrc'
alias zopen='file=$(find ~ -type f -name "*.pdf" | fzf) && nohup zathura "$file" &>/dev/null & disown'
# alias rea='(PIPEWIRE_LATENCY="64/48000" nohup pw-jack reaper > /dev/null 2>&1 &) && exit'
alias rea='(GDK_BACKEND=x11 PIPEWIRE_LATENCY="64/48000" nohup pw-jack reaper > /dev/null 2>&1 &) && exit'

# PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Pywal colors
(cat ~/.cache/wal/sequences &)

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
[[ -z "$KITTY_WINDOW_ID" ]] || fastfetch
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
