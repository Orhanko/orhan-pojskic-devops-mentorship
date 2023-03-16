#!/bin/bash

for file in /Users/orhanpojskic/Desktop/*
do 
    if [ -d "$file" ]
    then
        echo "$file is directory"
    elif [ -f "$file" ]
    then
        echo echo "$file is file"
    fi
done