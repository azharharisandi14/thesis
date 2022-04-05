#!/bin/bash

echo "running example: `date`"
currentdir=`pwd`

# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

# cleans output files
mkdir -p OUTPUT_FILES
mkdir -p REF_SEIS
mkdir -p GF_REF

rm -rf OUTPUT_FILES/*
rm -rf REF_SEIS/*
rm -rf GF_REF/*

rm DATA/CMTSOLUTION
cp scenarios/CMTSOLUTION_REF DATA/CMTSOLUTION

## links executables
#mkdir -p bin
#cd bin/
#rm -f *
#ln -s ~/programs/specfem3d/bin/xmeshfem3D
#ln -s ~/programs/specfem3d/bin/xgenerate_databases
#ln -s ~/programs/specfem3d/bin/xspecfem3D
#ln -s ~/programs/specfem3d/bin/xcombine_vol_data_vtk
#ln -s ~/programs/specfem3d/bin/xcreate_movie_shakemap_AVS_DX_GMT
#cd ../

# stores setup
cp DATA/meshfem3D_files/Mesh_Par_file OUTPUT_FILES/
cp DATA/Par_file OUTPUT_FILES/
cp DATA/CMTSOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/

# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

## runs in-house mesher
#if [ "$NPROC" -eq 1 ]; then
#  # This is a serial simulation
#  echo
#  echo "  running mesher..."
#  echo
#  ./bin/xmeshfem3D
#else
#  # This is a MPI simulation
#  echo
#  echo "  running mesher on $NPROC processors..."
#  echo
#  mpirun -np $NPROC ./bin/xmeshfem3D
#fi
## checks exit code
#if [[ $? -ne 0 ]]; then exit 1; fi

# decomposes mesh 
echo
echo "decomposing mesh..."
echo
./bin/xdecompose_mesh $NPROC ./MESH $BASEMPIDIR
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs database generation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running database generation..."
  echo
  ./bin/xgenerate_databases
else
  # This is a MPI simulation
  echo
  echo "  running database generation on $NPROC processors..."
  echo
  mpirun -np $NPROC ./bin/xgenerate_databases
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi


# forward simulation 
./change_simulation_type.pl -f


# runs simulation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running solver..."
  echo
  ./bin/xspecfem3D
else
  # This is a MPI simulation
  echo
  echo "  running solver on $NPROC processors..."
  echo
  mpirun -np $NPROC ./bin/xspecfem3D
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
echo `date`

cp OUTPUT_FILES/*.semd REF_SEIS/
cp OUTPUT_FILES/*.semd GF_REF/

#python convolve_stf.py REF_SEIS UC 1.96E-4 0.0035

gnuplot plot_all_seismograms.gnu
