# polarzsh theme (reliable git branch, no git segment outside repos)

setopt prompt_subst

# Return " [git::branch]" when inside a git repo, else empty
_polar_git_segment() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch="detached"
  print -r -- " %{$fg[green]%}[git::${branch}]%{$reset_color%}"
}

_polar_set_prompt() {
  PROMPT=$'%{$fg[blue]%}%~%{$reset_color%}$(_polar_git_segment)%{$fg[white]%} [%n@%m]%{$reset_color%}%{$fg[white]%} [%T]%{$reset_color%}\n%{$fg_bold[black]%}>%{$reset_color%} '
  PROMPT2="%{$fg_bold[black]%}%_> %{$reset_color%}"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _polar_set_prompt

# Ensure first prompt is correct immediately
_polar_set_prompt
