#!/bin/sh

if [ "$#" -eq 2 ]; then
    sed -e "/$1/ {
r $2
d }" < /dev/stdin
elif [ "$#" -eq 3 ]; then
    sed -e "/$1/ {
r $3
d }" < "$2"
else
    echo "Wrong number of arguments provided $#" && exit 1
fi
