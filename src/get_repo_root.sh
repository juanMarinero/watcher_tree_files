#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=5 :

get_repo_root(){
  SCRIPT_DIR="$(cd "$(dirname "${0:A}")" && pwd)"
  
  # Change to the specified directory
  cd "$dir" || return 1

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "$(git rev-parse --show-toplevel)"
  else
    echo "Current file "$SCRIPT_DIR" is not in a Git repository."
    return 1
  fi
}
