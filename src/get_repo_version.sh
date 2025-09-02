#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=5 :

get_repo_version(){
  local repo_root=$(get_repo_root)
  local git_version=$(git -C "$repo_root" describe --tags --abbrev=0 2>/dev/null)
  echo "$git_version"
}
