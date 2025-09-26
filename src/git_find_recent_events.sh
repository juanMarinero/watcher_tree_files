#!/usr/bin/env zsh

# vim: set ts=2 sts=2 sw=2 expandtab tw=0 foldcolumn=4 :

git_find_recent_events() {
  # Debug
  local dbg="${1:-false}"

  # Create associative array with composite keys
  typeset -A dict_events
  
  # Helper function to extract time and file from temp file
  extract_time_and_file() {
    local tmp_file=$1
    local -a result
    result=("${(@f)$(head -n 1 "$tmp_file")}")
    local time="${result[1]%% *}"
    local file="${result[1]#* }"
    echo "$time"
    echo "$file"
  }

  # Temporary file
  tmp_file=$(mktemp)

  # Events
  # Birth the first, so later "mod" must has a BIRTH_GAP time bigger
  events=("birth" "mod" "rm" "rm_uncommited" "rename_uncommited")


  # Functions for each event follow the syntax: <event>_func
  
  # `stat` time formats:
  #   %X	Time of last access (atime), in seconds since epoch
  #   %Y	Time of last modification (mtime), in seconds since epoch
  #   %Z	Time of last status change (ctime), in seconds since epoch
  #   %W	Time of file birth (creation), in seconds since epoch (may be 0 if unsupported)
  
  # Modify
  mod_func() {
    find . -type f -not -path './.git/*' -exec stat -c '%Y %n' {} + 2>/dev/null | \
      sort -nr | head -n 1 > "$tmp_file"
  }

  # Birth of new file
  birth_func() {
    find . -type f -not -path './.git/*' -exec stat -c '%W %n' {} + 2>/dev/null | \
      sort -nr | head -n 1 > "$tmp_file"
  }
  
  # Git remove
  rm_func() {
    # Get last Git committed removal
    git log --diff-filter=D --name-only --pretty=format:'%at %H' -1 2>/dev/null | \
    awk 'NR==1 {timestamp=$1} NR>1 {if (NF>0) print timestamp, $0}' | \
    tail -n 1 > "$tmp_file"
  }

  # Removed but not commited
  # TODO
  # Git doesn't track or remember the creation time of untracked files or the first time it saw an untracked file
  rm_uncommited_func() {
    echo "0 fix__rm_uncommited_func"  > "$tmp_file"
  }
  # Alternative, create a watcher of commands "rm" and "git rm".
  # If event triggered then write times and file to a fixed file
  # So rm_uncommited_func should read from that file

  # Renamed but not commited
  # TODO
  # The mv command doesn't change the file's content or metadata timestamps - it just changes the directory entry pointing to the file.
  # To update the timestamp when moving, use touch afterwards
  # Git itself does not track or remember the creation time of untracked files or the first time it saw an untracked file.
  # `git mv` is just a shortcut for `mv oldfile nefile && git rm oldfile && git add newfile`, thus:
  #   - It does not by itself register a rename
  #   - The rename is inferred later by Git heuristics on commit.
  rename_uncommited_func() {
    echo "0 fix__rename_uncommited_func"  > "$tmp_file"
  }
  # Alternative, create a watcher of commands "mv" and "git mv".
  # If event triggered then write times and file to a fixed file
  # So rename_uncommited_func should read from that file


  # Create the associative array and assign function names as values
  typeset -A dict_funcs
  for (( i=1; i <= ${#events}; i++ )); do
    dict_funcs[${events[i]}]="${events[i]}_func"
  done
  # DBG
  if $dbg; then
    echo "Functions dictionary:" >&2
    for key in "${(@k)dict_funcs}"; do
      echo "$key => ${dict_funcs[$key]}" >&2
    done
    echo >&2
  fi
  
  # Find last modified/rm/added/... file and its timestamp
  for event in "${events[@]}"; do
    func_name=${dict_funcs[$event]}
    $func_name  # Call the function
    sleep 0.1
    data=("${(@f)$(extract_time_and_file "$tmp_file")}")
    dict_events["${event},time"]=$data[1]
    dict_events["${event},file"]=$data[2]
  done

  # DBG
  if $dbg; then
    echo "Newest file by event:" >&2
    for key in ${(ko)dict_events}; do
      echo "$key -> ${dict_events[$key]}" >&2
    done
    echo >&2
  fi
  
  # Cleanup
  \rm "$tmp_file"
  
  # Get file of highest timestamp
  highest_time=0
  BIRTH_GAP=5
  # Sorted keys only to get Birth time the first, so later "mod" must be bigger than a BIRTH_GAP
  for key in ${(ok)dict_events}; do
    value=${dict_events[$key]}
    # Remove surrounding quotes from key if present
    stripped_key=${key//\"/}
    if [[ $stripped_key == *,time ]]; then
      if (( value > ( highest_time + BIRTH_GAP ) )); then
        highest_time=$value
        highest_time_file_keys=${stripped_key%,time}',file'
        highest_time_file_event=${stripped_key%%,*}
      fi
    fi
  done
  highest_time_file=${dict_events["$highest_time_file_keys"]}

  # DBG
  if $dbg; then
    printf 'Highest time: ' >&2
    print -P '%D{%Y-%m-%d %H:%M:%S}' "$highest_time" >&2
    echo "Event:    $highest_time_file_event" >&2
    echo "For file: $highest_time_file" >&2
    echo >&2
  fi

  # Return the corresponding file, event and time
  echo \
    "$highest_time_file" \
    "$highest_time_file_event" \
    "$highest_time"
}
