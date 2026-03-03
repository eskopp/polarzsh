# polarzsh theme (stable)

_polar_git_segment() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local branch dirty=""
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch="detached"

  # Dirty marker inside the git brackets: [git::main*]
  command git diff --no-ext-diff --quiet --ignore-submodules 2>/dev/null || dirty="%{$fg[red]%}*%{$fg[green]%}"

  print -r -- " %{$fg[green]%}[git::${branch}${dirty}]%{$reset_color%}"
}

_polar_set_prompt() {
  print -r -- ""
  # Time as HH:MM with leading zero guaranteed
  local now="%D{%H:%M}"
  local seg="$(_polar_git_segment)"

  PROMPT=$'%{$fg[blue]%}%~%{$reset_color%}'"${seg}"$'%{$fg[white]%} [%n@%m]%{$reset_color%}%{$fg[white]%} ['"${now}"$']%{$reset_color%}\n%{$fg[cyan]%}➜%{$reset_color%} '
  PROMPT2="%{$fg[cyan]%}➜%{$reset_color%} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _polar_set_prompt

typeset -ga precmd_functions
precmd_functions=(${precmd_functions:#_polar_set_prompt} _polar_set_prompt)

_polar_set_prompt
