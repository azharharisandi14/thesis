#!/bin/bash

echo "running moment tensor inversion (NLCG-6)"
currentdir=`pwd`

# get the number of processors,
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

mkdir -p ITERATIONS
mkdir -p TEST_SIMULATION
mkdir -p GRADS

rm -rf TEST_SIMULATION/*
rm -rf GRADS/*
rm -rf ITERATIONS/*
rm -f misfits.txt
rm -f nlcg_params.txt

rm DATA/CMTSOLUTION
cp scenarios/CMTSOLUTION_SYN ./DATA/CMTSOLUTION