#! /bin/bash

# Script to submit an array job to SGE based on a parameter file.

if [ -z $2 ]; then
	echo "Usage: "
	echo "	$0 my_genesis_script.g my_params.par [options-to-qsub]"
	echo "(Run in the script directory.)"
	exit -1;
fi

genfile=$1
parfile=$2
shift 2

# Get the number of trials from the parameter file
trials=`head -1 $parfile | cut -d " " -f 1` 
#awk 'BEGIN{ getline; print $1}'`

echo "GENESIS script: $genfile; param. file: $parfile with $trials trials."
echo

par2db.pl $parfile
echo 
qsub -t 1:$trials $* ./sim_genesis_1par.sh $genfile $parfile

