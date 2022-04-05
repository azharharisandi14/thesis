#!/bin/bash

DIR=OUTPUT_FILES/DATABASES_MPI
COMP=Z
NPROC=2

DATA=$(ls $DIR | grep velocity_$COMP)
NFILES=$(ls $DIR | grep velocity_$COMP | wc -l)
#STOP=$(expr $NFILES / 2)
STOP=4

i=0
for d in $DATA; do
 if [[ "$i" -lt "$STOP" ]]; then 
 ./bin/xcombine_vol_data_vtk 0 1 ${d:11:19} ./$DIR ./vtk_vol 1
 #echo $i : ${d:11:19}
 ((i++));
fi
done

#echo $DATA

