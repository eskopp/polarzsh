# polarzsh theme (robust against other prompt modifiers)

_polar_git_segment() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch="detached"
  print -r -- " %{$fg[green]%}[git::${branch}]%{$reset_color%}"
}

_polar_git_dirty() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  command git diff --no-ext-diff --quiet --ignore-submodules 2>/dev/null || print -r -- " %{$fg[red]%}*%{$reset_color%}"
}

_polar_set_prompt() {
  local seg dirty
  seg="$(_polar_git_segment)"
  dirty="$(_polar_git_dirty)"

  PROMPT=$'%{$fg[blue]%}%~%{$reset_color%}'"${seg}${dirty}"$'%{$fg[white]%} [%n@%m]%{$reset_color%}%{$fg[white]%} [%T]%{$reset_color%}\n%{$fg[cyan]%}➜%{$reset_color%} '
  PROMPT2="%{$fg[cyan]%}➜%{$reset_color%} "
}

# Ensure our prompt is applied LAST before each prompt render
autoload -Uz add-zsh-hook
add-zsh-hook precmd _polar_set_prompt

# Also pin to the end of precmd_functions (some tools reorder hooks)
typeset -ga precmd_functions
precmd_functions=(${precmd_functions:#_polar_set_prompt} _polar_set_prompt)

# First prompt should be correct immediately
_polar_set_prompt
