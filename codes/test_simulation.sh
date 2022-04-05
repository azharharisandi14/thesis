#!/bin/bash

# remove all from test simulation
rm -rf TEST_SIMULATION/*

# change simulation type to forward
./change_simulation_type.pl -f
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`


echo ""
echo "running test simulation"
echo ""


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

# copy to test simulation directory
cp OUTPUT_FILES/UC*.semd TEST_SIMULATION/.

# python convolve_stf.py TEST_SIMULATION UC 1.96E-04 0.0035
