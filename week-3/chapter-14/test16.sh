#! /bin/bash

while [ -n "$1" ]
do
case "$1" in
    -a) echo "Found the -a otpion" ;;
    -b) echo "Found the -b otpion" ;;
    -c) echo "Found the -c otpion" ;;
    --) shift
    break ;;
    *) echo "$1 is not an option";;
    esac
     shift
    done

    count=1
    for param in $@
    do
    echo "Parametar #$count: $param"
    count=$[ $count + 1 ]
    done