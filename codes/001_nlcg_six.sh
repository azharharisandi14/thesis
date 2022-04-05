#!/bin/bash

currentdir=`pwd`

# get the number of processors,
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `

i=1

echo "###############################"
echo "starting iteration $i"
echo "###############################"
echo " "

cp ./DATA/CMTSOLUTION ./ITERATIONS/CMTSOLUTION_$i
# change simulation type to forward
./change_simulation_type.pl -f

# run forward simulation
if [ "$NPROC" -eq 1 ]; then
    # serial solver
    echo
    echo "running solver ..."
    echo
    ./bin/xspecfem3D
else
    # MPI simulation
    echo
    echo "running solver on $NPROC processors..."
    echo
    mpirun -np $NPROC ./bin/xspecfem3D
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# convolve with stf
python convolve_stf.py OUTPUT_FILES UC 1.96E-4 0.0035

if [[ $? -ne 0 ]]; then exit 1; fi

rm -rf SEM/*
# create adjsrc
python calculate_adjsrc_waveform.py

# convolve with stf
python convolve_stf.py SEM UC 1.96E-4 0.0035

if [[ $? -ne 0 ]]; then exit 1; fi

cp DATA/STATIONS DATA/STATIONS_ADJOINT

echo "computing misfits"
echo " "
# compute misfits
python calculate_misfit.py >> misfits.txt

# change simulation type to adj(2)
./change_simulation_type.pl -a

echo " "
echo "start adjoint simulation"

# adjoint simulation
if [ "$NPROC" -eq 1 ]; then
    # serial solver
    echo
    echo "running solver ..."
    echo
    ./bin/xspecfem3D
else
    # MPI simulation
    echo
    echo "running solver on $NPROC processors..."
    echo
    mpirun -np $NPROC ./bin/xspecfem3D
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

i=$(($i+1))