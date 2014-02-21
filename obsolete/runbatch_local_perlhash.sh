#! /bin/bash

# This script allows you to run a batch of simulations locally just like you
#    would on the cluster with qsub.
#
# USAGE:
#    First, create your parameter database with
#        create_perlhash_param_db
#    Next, run your batch using this script:
#        runbatch_local_perlhash.sh <genesis script> <params file> <startrow> <endrow>
#
# Authors:
#    Cengiz Gunay, Emory University
#    Jeremy Edgerton, Emory University

if [ -z "$3" ]; then
   echo "Need to specify GENESIS script, parameter file, and parameter row(s)."
   echo ""
   echo "Optional 5th argument = name for run status text file."
   echo "If none supplied, files will be named batchrun.(number)."
   echo ""
   echo "Usage 1: "
   echo "   $0 genesis_script parameter_file start_row"
   echo "Usage 2: "
   echo "   $0 genesis_script parameter_file start_row end_row"
   echo "Usage 3: "
   echo "   $0 genesis_script parameter_file start_row end_row file_name"
   exit -1
else
    genfile=$1
    parfile=$2
    startrow=$3
    if [ -z "$4" ]; then
        endrow=$startrow
    else
        endrow=$4
    fi
    if [ -z "$5" ]; then
        fname=`echo "batchrun"`
    else
        fname=$5
    fi
fi

trap exit INT

export GENESIS_PAR_ROW

for (( i = $startrow; i <= $endrow; i = $[ $i + 1 ] )); do
    # Output text file name:
    textfile=`echo "$fname$i.txt"`
    echo "fname: $fname, textfile: $textfile"

    # Read parameter values.
    GENESIS_PAR_ROW=`do_sim_num $parfile $i`

    # Run genesis 
    genesis -nox -batch -notty $genfile > $textfile

    [ "$?" != "0" ] && echo "GENESIS run failed, terminating job!" && exit -1

    echo "Ending job"
    date
done
