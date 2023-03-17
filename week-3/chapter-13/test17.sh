#! /bin/bash

for broj in 1 2 3 4 5 6 7 8 9 10 
do
    if [ $broj -eq 5 ] 
    then
        break 
    fi
echo "Broj iteracije: $broj"
done
echo "For petlja je zavrsena break-om"