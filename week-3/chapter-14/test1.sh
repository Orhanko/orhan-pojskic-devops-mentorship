#! /bin/bash

factorial=1

for (( number = 1; number <= $1 ; number++ ))
do 
    factorial=$[ $factorial * $number ]
done
echo Faktorijel broja $1 je $factorial