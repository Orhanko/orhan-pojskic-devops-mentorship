#!/bin/bash 

for file in /Users/orhanpojskic/Desktop/* /Users/orhanpojskic/Desktop/badtest 
do
    if [ -d "$file" ] 
    then
        echo "$file is a directory" 
    elif [ -f "$file" ]
    then
        echo "$file is a file" 
    else
        echo "$file doesn't exist" 
    fi
done