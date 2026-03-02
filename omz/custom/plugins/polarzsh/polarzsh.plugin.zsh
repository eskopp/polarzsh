# polarzsh plugin

export PATH="$HOME/.local/bin:$PATH"

alias cls="clear"

# Enable zoxide if available (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
