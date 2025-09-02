#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=5 :

watcher_tree_files() {
  
  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        echo "Usage:"
        echo "  cd <path>"
        echo "  watcher_tree_files [flags][options]"
        exit 0
        ;;
      --version)
        echo "Version: $(get_repo_version)"
        exit 0
        ;;
      --which)
        echo "Program location: $(get_repo_version)"
        exit 0
        ;;
      --debug)
        dbg=true
        shift
        ;;
      -v|--verbose)
        verbose=true
        shift
        ;;
      -d|--directory)
        dir=$2
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  # Call functions with options after parsing
  # TODO
}
