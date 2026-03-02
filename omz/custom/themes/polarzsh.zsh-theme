# polarzsh theme (stable layout, prompt set immediately)

setopt prompt_subst

# Git prompt style used by oh-my-zsh's git_prompt_info
GIT_CB="git::"
ZSH_THEME_SCM_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_PREFIX="${ZSH_THEME_SCM_PROMPT_PREFIX}${GIT_CB}"
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

_polar_git_segment() {
  local gi
  gi="$(git_prompt_info 2>/dev/null)"
  if [[ -n "$gi" ]]; then
    print -r -- " $gi"
  else
    # Placeholder so layout never "jumps"
    print -r -- " %{$fg[green]%}[git::-]%{$reset_color%}"
  fi
}

_polar_set_prompt() {
  PROMPT=$'%{$fg[blue]%}%~%{$reset_color%}$(_polar_git_segment)%{$fg[white]%} [%n@%m]%{$reset_color%}%{$fg[white]%} [%T]%{$reset_color%}\n%{$fg_bold[black]%}>%{$reset_color%} '
  PROMPT2="%{$fg_bold[black]%}%_> %{$reset_color%}"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _polar_set_prompt

# Set it once immediately so the very first prompt is correct
_polar_set_prompt
