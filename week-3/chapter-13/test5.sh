#!/bin/bash

file="/Users/orhanpojskic/Desktop/DevOps/Task3/chapter-13/states"
for state in $(cat $file) 
do
echo "Visit beautiful $state" 
done