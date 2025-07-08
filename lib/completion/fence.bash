# Autocomplete for FENCE in Bash shell

_fence_completion() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  local branches=$(git branch --format='%(refname:short)')

  COMPREPLY=( $(compgen -W "${branches}" -- "$cur") )
}

complete -F _fence_completion fence
