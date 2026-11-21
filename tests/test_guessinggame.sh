#!/usr/bin/env bash
#
# Tests for guessinggame.sh. Run with: make test
# Each test builds a temporary directory with a known number of files,
# pipes guesses into the game and checks the output and exit status.

set -uo pipefail

GAME="$(cd "$(dirname "$0")/.." && pwd)/guessinggame.sh"
pass=0
fail=0

# make_dir N: temporary directory with N regular files, plus a hidden file
# and a subdirectory that must NOT be counted.
make_dir() {
  local d
  d=$(mktemp -d)
  for ((i = 1; i <= $1; i++)); do touch "$d/file_$i.txt"; done
  touch "$d/.hidden"
  mkdir "$d/subdir"
  echo "$d"
}

# check NAME INPUT DIR EXPECTED_STATUS EXPECTED_TEXT
check() {
  local name="$1" input="$2" dir="$3" want_status="$4" want_text="$5" out status
  out=$(printf "%b" "$input" | bash "$GAME" "$dir" 2>&1)
  status=$?
  if [[ $status -eq $want_status && "$out" == *"$want_text"* ]]; then
    echo "PASS  $name"
    pass=$((pass + 1))
  else
    echo "FAIL  $name (exit $status, wanted $want_status; missing: '$want_text')"
    while IFS= read -r line; do echo "      $line"; done <<< "$out"
    fail=$((fail + 1))
  fi
}

d3=$(make_dir 3)
d0=$(make_dir 0)
trap 'rm -rf "$d3" "$d0"' EXIT

check "correct first guess"           '3\n'           "$d3" 0 "in 1 attempt(s)"
check "too low then correct"          '1\n3\n'        "$d3" 0 "Too low"
check "too high then correct"         '9\n3\n'        "$d3" 0 "Too high"
check "counts attempts"               '1\n9\n3\n'     "$d3" 0 "in 3 attempt(s)"
check "ignores hidden files and dirs" '3\n'           "$d3" 0 "There are 3 files"
check "rejects text input"            'abc\n3\n'      "$d3" 0 "Please enter a whole number"
check "rejects mixed input"           '1a\n3\n'       "$d3" 0 "Please enter a whole number"
check "rejects negative numbers"      '-1\n3\n'       "$d3" 0 "Please enter a whole number"
check "rejects empty input"           '\n3\n'         "$d3" 0 "Please enter a whole number"
check "leading zeros are decimal"     '03\n'          "$d3" 0 "Congratulations"
check "empty directory"               '0\n'           "$d0" 0 "There are 0 files"
check "end of input exits 1"          '1\n'           "$d3" 1 "The answer was 3"
check "bad directory exits 2"         '3\n'           "/no/such/dir" 2 "is not a directory"

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
