#! /bin/bash

Broj=5

while [ $Broj -ge 0 ]
do
echo "While petlja sa brojem: $Broj"
    for (( a = 1; a <= 3; a++ ))
    do
        Reuzltat=$[ $Broj * $a ]
        echo "      Unutrasnja for petlja: $Broj * $a = $Reuzltat"
    done
    
    Broj=$[ $Broj - 1 ]

done


#for (( a = 1; a <= 3; a++ ))
#do 
    #echo " *** Pocetak sa brojem: $a ***"
    #for (( b = 1; b <= 3; b++))
   # do
  #      echo "      Druga petlja sa indeksom $b. koja je unutar a($a). petlje"
 #   done
#done