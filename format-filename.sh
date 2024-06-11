#!/bin/env bash

# Description: Removes spaces in filenames in current directory
#              Replaces/Removes a specific pattern

# Text/Color format for output
RST="\e[0m"
BLD="\e[1m"
DIM="\e[2m"
ULN="\e[4m"
RED="\e[31m"
GRN="\e[32m"
YLW="\e[33m"

# Replaces the spaces in a file with underscores
for file in *; do
    mv "$file" > /dev/null 2>&1 `echo $file | tr ' ' '_'`
done

# Prints other commands user can use
printf "\n${GRN}Formated your files in ${BLD}$PWD${RST}\n"
printf "${DIM}To${RST} ${RED}remove${RST} ${DIM}a string pattern:${RST} $0 ${ULN}rm${RST} ${ULN}<string>${RST}\n"
printf "${DIM}To${RST} ${YLW}replace${RST} ${DIM}a string pattern:${RST} $0 ${ULN}<string>${RST} ${ULN}<new_string>${RST}\n\n"

# Either removes or replaces the string pattern
if ! [[ -z $2 ]]; then
    if [ $1 == "rm" ]; then
        for f in *$2*; do
            mv -- "$f" "${f/$2/}"
        done
    else
        for f in *$1*; do
            mv -- "$f" "${f/$1/$2}"
        done
    fi
fi