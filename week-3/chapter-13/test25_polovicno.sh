#! /bin/bash 

IFS=:
for folder in /Users/orhanpojskic/Desktop/DevOps/Task3/
do
    echo "$folder:"
    for file in $folder/* 
    do
        if [ -x $file ] 
        then
            echo "  $file"
    fi 
    done
done
