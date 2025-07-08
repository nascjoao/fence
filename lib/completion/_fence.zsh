# Autocomplete for FENCE in Zsh shell

#autoload
_fence() {
  local branches
  branches=("${(@f)$(git branch --format='%(refname:short)')}")

  _arguments \
    '1:branch name:->branch'

  case $state in
    branch)
      _values 'branches' $branches
      ;;
  esac
}

compdef _fence fence
