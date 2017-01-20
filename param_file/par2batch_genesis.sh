#! /bin/bash

function usage() {
    cat <<EOF 

This script reads a range of trials from a parameter file and outputs
a single batch file that will run all simulations. Each row of the
batch file executes one Genesis simulation with the corresponding
parameter values.

Usage: 
${0##*/} genfile parfile trial_range > batch_file.sh

Input arguments:
  genfile: Genesis script (e.g., myfunc.g).
  parfile: Parameter file name (e.g., mymodel.par).
  trial_range: (Optional) Range of trials to read from parameter file
  	(e.g., 1-100). If missing, all trials will be selected.
EOF
}

genfile=$1
parfile=$2
trial_range=${3:-$parfile}

PSN_PRINT=1 run_local.sh $trial_range sim_genesis_1par.sh $genfile $parfile
