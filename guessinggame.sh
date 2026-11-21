#!/usr/bin/env bash
#
# guessinggame.sh: guess how many files are in a directory.
#
# Usage: ./guessinggame.sh [DIRECTORY]
#   DIRECTORY defaults to the current working directory.
#
# The player keeps guessing until correct. Each wrong guess gets a
# "too high" or "too low" hint, and non-numeric input is rejected.
# Exit status: 0 on a correct guess, 1 if input ends first, 2 on usage error.

set -uo pipefail

# Count regular, non-hidden files directly inside a directory.
count_files() {
  local dir="$1"
  find "$dir" -maxdepth 1 -type f ! -name '.*' | wc -l | tr -d ' '
}

# Return 0 if the argument is a non-negative whole number.
is_whole_number() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

main() {
  local dir="${1:-.}"
  if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a directory." >&2
    return 2
  fi

  local answer guess attempts=0
  answer=$(count_files "$dir")

  echo "Directory guessing game: how many files are in $(cd "$dir" && pwd)?"

  while true; do
    printf "Enter your guess: "
    if ! read -r guess; then
      echo
      echo "No more input. The answer was $answer."
      return 1
    fi

    if ! is_whole_number "$guess"; then
      echo "Please enter a whole number (e.g. 3)."
      continue
    fi

    attempts=$((attempts + 1))
    guess=$((10#$guess))            # treat leading zeros as decimal

    if (( guess < answer )); then
      echo "Too low, try again."
    elif (( guess > answer )); then
      echo "Too high, try again."
    else
      echo "Congratulations! There are $answer files. You got it in $attempts attempt(s)."
      return 0
    fi
  done
}

main "$@"
