#! /bin/bash

for (( a = 1; a <= 3; a++ ))
do 
    echo " *** Pocetak sa brojem: $a ***"
    for (( b = 1; b <= 3; b++))
    do
        echo "      Druga petlja sa indeksom $b. koja je unutar a($a). petlje"
    done
done