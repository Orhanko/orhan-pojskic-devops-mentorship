#! /bin/bash

Broj=1

while [ $Broj -lt 10 ]
do
    if [ $Broj -eq 5 ]
    then
        break
    fi
    echo Broj iteracije: $Broj
    Broj=$[ $Broj + 1 ]
done
echo While petlja je zavrsena break-om