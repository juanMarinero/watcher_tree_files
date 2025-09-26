#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=4 :

git_info_lastfile() {
  # Check if the directory is a Git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    record_msg "❌ Not a Git repository"
    exit 1
  fi

  # Save directory
  local save_dir="${1:-$HOME/Downloads/tree-monitor}"
  mkdir -p "$save_dir"

  # Debug
  local dbg=${2:-false} # default false

  # Get the last file with most recent event
  local results=($(git_find_recent_events $dbg))
  local last_file=${results[1]}
  local event=${results[2]}
  local event_time=${results[3]}

  if [ -z "$last_file" ]; then
    echo "No files found"
    exit 1
  fi

  # Remove initial "./" and replace all "/" with "__"
  local filename=$(echo "$last_file" | sed 's|^\./||' | sed 's/\//__/g')
  # Add time and event in log file
  filename="$save_dir/${event_time}_-_${event}_-_${filename}.txt"
  if [ ! -s "$filename" ]; then
    file_is_empty_at_start_of_script=true
  else
    file_is_empty_at_start_of_script=false
  fi
  record_msg() {
    if [ "$file_is_empty_at_start_of_script" = true ]; then
      echo "$1" | tee -a "$filename" > /dev/tty
    else
      if $dbg; then
        echo "$1" >&2
      fi
    fi
  }

  "$dbg" && echo "Log file: $filename" >&2
  record_msg "Last event is:    $event"
  record_msg "On file:          $last_file"
  record_msg "Time since epoch: $event_time"
  record_msg "----------------------------------------"

  # Check Git status
  git_status=$(git status --porcelain "$last_file" 2>/dev/null)

  if [ $? -ne 0 ]; then
    record_msg "❌ Not a Git repository"
    exit 1
  fi

  # Parse Git status
  if [ -z "$git_status" ]; then
    record_msg "✅ Tracked and clean (no modifications)"
  else
    status_code=${git_status:0:2}
    case $status_code in
      " M") record_msg "📝 Modified (tracked but changed)" ;;
      "M ") record_msg "📝 Staged modified" ;;
      "A ") record_msg "➕ Added (staged)" ;;
      "??") record_msg "🆕 Untracked" ;;
      "!!") record_msg "👻 Ignored" ;;
      " D") record_msg "🗑️  Deleted (not staged)" ;;
      "D ") record_msg "🗑️  Deleted (staged)" ;;
      " R") record_msg "↔️  Renamed (not staged)" ;;
      "R ") record_msg "↔️  Renamed (staged)" ;;
      " C") record_msg "📋 Copied (not staged)" ;;
      "C ") record_msg "📋 Copied (staged)" ;;
      " U") record_msg "⚡ Updated but unmerged" ;;
      *) record_msg "❓ Unknown status: $status_code" ;;
    esac
  fi

  # Check if file is tracked
  if git ls-files --error-unmatch "$last_file" >/dev/null 2>&1; then
    record_msg "📋 Tracked by Git"

      # Get last commit info for this file
      last_commit=$(git log --oneline -1 -- "$last_file" 2>/dev/null)

      if [ -n "$last_commit" ]; then
        record_msg "📜 Last commit involving this file:"
        record_msg "   $last_commit"
      else
        record_msg "📜 No commits found for this file (may be newly added)"
      fi
    else
      record_msg "🚫 Not tracked by Git"
  fi

  # Show file info
  record_msg "----------------------------------------"
  [[ -f "$last_file" ]] && record_msg "File info: $(ls -la $last_file)" 

  # Return the corresponding file, event and time
  echo $results
}
