#!/bin/bash

var1=10

while echo $var1
[ $var1 -ge 0 ]
do
    echo "Ispis unutar while petlje jer je $var1 vece ili jednako od 0"
    var1=$[ var1 - 1 ]
done