# polarzsh theme (stable, no prompt_subst, no $(...) in PROMPT)

_polar_git_segment() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch="detached"
  print -r -- "%{$fg[green]%}[git::${branch}]%{$reset_color%}"
}

_polar_git_dirty() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  command git diff --no-ext-diff --quiet --ignore-submodules 2>/dev/null || print -r -- "%{$fg[red]%}*%{$reset_color%}"
}

_polar_set_prompt() {
  print -r -- ""

  local seg dirty
  seg="$(_polar_git_segment)"
  dirty="$(_polar_git_dirty)"

  if [[ -n "$seg" ]]; then
    seg=" ${seg}${dirty}"
  fi

  PROMPT=$'%{$fg[blue]%}%~%{$reset_color%}'"${seg}"$'%{$fg[white]%} [%n@%m]%{$reset_color%}%{$fg[white]%} [%T]%{$reset_color%}\n%{$fg[cyan]%}➜%{$reset_color%} '
  PROMPT2="%{$fg[cyan]%}➜%{$reset_color%} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _polar_set_prompt

# Ensure it runs last
typeset -ga precmd_functions
precmd_functions=(${precmd_functions:#_polar_set_prompt} _polar_set_prompt)

# First prompt correct immediately
_polar_set_prompt
