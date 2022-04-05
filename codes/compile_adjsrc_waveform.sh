#!/bin/bash

currentdir=$1

cd $currentdir/SEM
# compile adjoint_source tool
if [ ! -e xcreate_adjsrc_waveform ]; then
  # creates adjoint sources
  cd ~/programs/specfem3d/utils/adjoint_sources/waveform

  # fortran compiler (as specified in Makefile)
  FC=`grep '^FC .*' ../../../Makefile | cut -d = -f 2 | sed "s/^[ \t]*//"`
  if [ "$FC" == "" ]; then echo "fortran compiler not found, exiting..."; exit 1; fi
  CC=`grep '^CC .*' ../../../Makefile | cut -d = -f 2 | sed "s/^[ \t]*//"`
  if [ "$CC" == "" ]; then echo "C compiler not found, exiting..."; exit 1; fi

  echo "compiling xcreate_adjsrc_traveltime:"
  echo "  using fortran compiler = $FC"
  echo "  using C compiler       = $CC"
  echo

  cp Makefile Makefile.host
  sed -i "s:F90 .*:F90 = $FC:" Makefile.host
  sed -i "s:CC .*:CC = $CC:" Makefile.host

  rm -rf xcreate_adjsrc_waveform
  make -f Makefile.host
  # checks exit code
  if [[ $? -ne 0 ]]; then exit 1; fi

  cp -v xcreate_adjsrc_waveform $currentdir/SEM/
  cd $currentdir
fi
if [ ! -e SEM/xcreate_adjsrc_waveform ]; then echo "please make xcreate_adjsrc_waveform and copy to SEM/"; exit 1; fi
