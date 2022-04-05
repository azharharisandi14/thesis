#!/bin/bash

t_start=$1
t_end=$2
network="UC"
comp="FXX"
en="semd"
datadir="REF_SEIS"
currentdir=`pwd`

# compile adjoint source
echo compiling xcreate_adjsrc_waveform
./compile_adjsrc_waveform.sh $currentdir

rm -f SEM/STATIONS_ADJOINT

# reference adjoint station
# for station in ST01 ST02 ST03 ST04 ST05 ST06 ST07 ST08
for station in ST02
do	
	# station="ST01"

	if [ "$t_start" == "" ] || [ "$t_end" == "" ]; then echo "insert start and endtime window"; exit 1; fi

	echo
	echo 
	echo "adjoint sources:"

	# needs traces
	sta=$network.$station
	rm -f SEM/$sta.*
	cp -v OUTPUT_FILES/$sta.* SEM/

	cd SEM
	# create adjoint sources
	./xcreate_adjsrc_waveform $t_start $t_end 0 $sta.* ../$datadir
	if [[ $? -ne 0 ]]; then exit 1; fi
	if [ ! -e $sta.$comp.adj ]; then echo "error creating adjoint sources, please check"; exit 1; fi
	echo

	grep $station ../DATA/STATIONS >> ./STATIONS_ADJOINT
	cd ../
done

cd SEM
cp -v ./STATIONS_ADJOINT ../DATA/
cd ../


