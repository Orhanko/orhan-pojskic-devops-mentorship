#! /bin/bash

for (( a = 1; a < 4 ; a++ ))
do
    echo "Vanjska for petlja: $a"
    for (( b = 1; b < 100; b++ ))
    do
        if [ $b -gt 4 ]
        then
            break 2
        fi
        echo "      Unutrasnja \"for\" petlja: $b"
    done
done