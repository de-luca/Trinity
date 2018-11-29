# ⟁ Trinity ⟁
# Based on geometry
# geometry: https://github.com/geometry-zsh/geometry

PROMPT_LOCAL="⟁"
PROMPT_SSH="▽"

trinity_prompt() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo $PROMPT_SSH
    else
        echo $PROMPT_LOCAL
    fi
}

PROMPT_OK="%{$fg[green]%}$(trinity_prompt)%{$reset_color%}"
PROMPT_FAIL="%{$fg[red]%}$(trinity_prompt)%{$reset_color%}"

PROMPT_LINE='◈'

trinity_host() {
    host_string=""

    if [[ $LOGNAME != $USER ]] || [[ $UID == 0 ]] || [[ -n $SSH_CONNECTION ]]; then
        host_string="${host_string}%B[%b"

        if [[ $USER == 'root' ]]; then
            host_string="${host_string}%{$fg[red]%}%B$USER%b%{$reset_color%}"
        else
            host_string="${host_string}$USER"
        fi

        if [[ $LOGNAME == $USER ]] || [[ $UID == 0 ]] && [[ -n $SSH_CONNECTION ]]; then
            host_string="${host_string}%B@%b"
        fi

        if [[ -n $SSH_CONNECTION ]]; then
            host_string="${host_string}%m"
        fi

        host_string="${host_string}%B]%b "
    fi

    echo $host_string
}

GIT_DIRTY="%{$fg[red]%}⬡%{$reset_color%}"
GIT_CLEAN="%{$fg[green]%}⬢%{$reset_color%}"
GIT_REBASE="\uE0A0"
GIT_UNPULLED="⇣"
GIT_UNPUSHED="⇡"

trinity_git_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

trinity_git_dirty() {
  if test -z "$(git status --porcelain --ignore-submodules 2> /dev/null)"; then
    echo $GIT_CLEAN
  else
    echo $GIT_DIRTY
  fi
}

trinity_git_rebase_check() {
  git_dir=$(git rev-parse --git-dir 2> /dev/null)
  if test -d "$git_dir/rebase-merge" -o -d "$git_dir/rebase-apply"; then
    echo " $GIT_REBASE"
  fi
}

trinity_git_remote_check() {
  local_commit=$(git rev-parse @ 2>&1)
  remote_commit=$(git rev-parse @{u} 2>&1)
  common_base=$(git merge-base @ @{u} 2>&1)

  if [[ $local_commit == $remote_commit ]]; then
    echo ""
  else
    if [[ $common_base == $remote_commit ]]; then
      echo " $GIT_UNPUSHED"
    elif [[ $common_base == $local_commit ]]; then
      echo " $GIT_UNPULLED"
    else
      echo " $GIT_UNPUSHED$GIT_UNPULLED"
    fi
  fi
}

trinity_git_symbol() {
  text="$(trinity_git_rebase_check)$(trinity_git_remote_check)"
  if [ ! -z "$text" ]; then
    echo " %F{242}::%{$reset_color%}$text"
  fi
}

trinity_git_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "$(trinity_git_branch)$(trinity_git_symbol) %F{242}::%{$reset_color%} $(trinity_git_dirty)"
  fi
}

trinity_set_cmd_title() {
  print -n '\e]0;'
  print -n "$2 @ "
  print -nrD "$PWD"
  print -n '\a'
}

trinity_set_title() {
  print -n '\e]0;'
  print -Pn '%~'
  print -n '\a'
}

trinity_render() {
  PROMPT='%(?.$PROMPT_OK.$PROMPT_FAIL) $(trinity_host)%{$fg[blue]%}%3~%{$reset_color%} '
  PROMPT2='$PROMPT_LINE '
  RPROMPT='$(trinity_git_info)'
}

trinity_setup() {
  autoload -U add-zsh-hook

  add-zsh-hook preexec  trinity_set_cmd_title
  add-zsh-hook precmd   trinity_set_title
  add-zsh-hook precmd   trinity_render
}

trinity_setup
