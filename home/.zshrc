# Created by newuser for 5.9
## Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias vi='nvim'
alias rc='nvim ~/.zshrc'
alias zopen='file=$(find ~ -type f -name "*.pdf" | fzf) && nohup zathura "$file" &>/dev/null & disown'
# PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Pywal colors
(cat ~/.cache/wal/sequences &)

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -z "$KITTY_WINDOW_ID" ]] || fastfetch
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
