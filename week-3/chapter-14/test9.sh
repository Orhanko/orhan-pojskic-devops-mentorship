#! /bin/bash 

if [ $# -ne 2 ]
then
    echo "Potrebna su dva parametra"
else
    total=$[ $1 + $2 ]
    echo Total: $total
fi
