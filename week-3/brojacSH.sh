#!/bin/bash

brojacTestova_ch_13=0
brojacTestova_ch_14=0
brojacTestova_ch_16=0

FILES_ch_13="/Users/orhanpojskic/Desktop/DevOps/Task3/chapter-13/*test*"
FILES_ch_14="/Users/orhanpojskic/Desktop/DevOps/Task3/chapter-14/*test*"
FILES_ch_16="/Users/orhanpojskic/Desktop/DevOps/Task3/chapter-16/*test*"

for f in $FILES_ch_13
    do
       brojacTestova_ch_13=$[ $brojacTestova_ch_13 + 1 ] 
    done

for f in $FILES_ch_14
do
    brojacTestova_ch_14=$[ $brojacTestova_ch_14 + 1 ]
done
echo "Trenutni broj uradjenih testova u chapter 13: $brojacTestova_ch_13"
echo "Trenutni broj uradjenih testova u chapter 14: $brojacTestova_ch_14"

for f in $FILES_ch_16
do
    brojacTestova_ch_16=$[ $brojacTestova_ch_16 + 1 ]
done
echo "Trenutni broj uradjenih testova u chapter 16: $brojacTestova_ch_16"
#ukupanBroj=$[ $brojacTestova_ch_13 + $brojacTestova_ch_14 + $brojacTestova_ch_16 ]
echo "Ukupan broj uradjenih skripti je: $ukupanBroj$[ $brojacTestova_ch_13 + $brojacTestova_ch_14 + $brojacTestova_ch_16 ]" 