#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    FILE="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$FILE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
FILE="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
if [[ ! "$1" = ""  ]] && [[ ! "$2" = "" ]]; then
    awk -v loop=$1 -v range=$2 'BEGIN{
      srand()
      do {
        numb = 1 + int(rand() * range)
        if (!(numb in prev)) {
           print numb
           prev[numb] = 1
           count++
        }
      } while (count<loop)
    }' > $FILE/list_of_non_repeating_random_numbers
else
    echo "SyntaxError - should be: [ bash, source or . ] generate_non_repeating_random_numbers [#Loop] [#Range]"
    echo "Example: bash generate_non_repeating_random_numbers 100 100"
    echo "Will generate 100 random (non repeating) numbers"
fi
