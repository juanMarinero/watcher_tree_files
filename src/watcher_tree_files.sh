#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=7 :

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
        echo "Program location: $(get_repo_root)"
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
      --cmd)
        cmd=${2:-main} # Default to "main"
        shift 2
        ;;
      --save-dir)
        save_dir=${2:-$HOME/Downloads/tree-monitor}
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  # Change directory
  ORIGINAL_DIR=$(pwd)
  [[ -n "$dir" && -d "$dir" ]] && { 
    cd "$dir" || { echo "Failed to cd into $dir"; exit 1; }
  }

  # Execute the command
  case $cmd in
    main)
      # TODO
      ;;
    test)
      echo "Running tests...\n" >&2
      # TODO
      ;;
    find_recent_events)
      echo "Finding recent events...\n" >&2
      git_find_recent_events "$dbg"
      ;;
    git_info_lastfile)
      echo "Getting info about last file-event...\n" >&2
      git_info_lastfile "$save_dir" "$dbg"
      ;;
    "")
      echo "No command specified. Use --cmd <command>"
      exit 1
      ;;
  esac

  # Return to original directory
  cd "$ORIGINAL_DIR"
}
