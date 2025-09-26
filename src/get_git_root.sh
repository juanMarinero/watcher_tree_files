#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=3 :

get_git_root(){
  local dir=${1:-$PWD}

  # Change directory
  ORIGINAL_DIR=$(pwd)
  [[ -n "$dir" && -d "$dir" ]] \
    && cd "$dir" || { echo "Failed to cd into $dir"; exit 1; }

  # Get the root of the Git repository
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "$(git rev-parse --show-toplevel)"
  else
    echo "Current directory "$dir" is not in a Git repository."
    exit 1
  fi

  # Return to original directory
  cd "$ORIGINAL_DIR"
}

get_repo_root(){
  echo $(get_git_root "$SOURCE_DIR/..")
}
