#! /bin/bash

if read -t 2 -p "Please enter yur name: " name 
then 
echo "Hello $name, welcome to my program"
else
echo "Sorry, 5 seconds run away!"
fi