# Autocomplete for FENCE in Fish shell
complete -c fence -a "(git branch --format='%(refname:short)')"
