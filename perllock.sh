#! /bin/bash

echo "Starting job on $HOSTNAME"
date

if [ -z "$2" ]; then
   echo "Need to specify GENESIS script and parameter file."
   echo ""
   echo "Usage: "
   echo "   $0 genesis_script parameter_file [genesis_executable]"
   exit -1
fi

trap exit INT

genfile=$1
parfile=$2

genexec=genesis	# Default	
[ -n "$3" ] && genexec=$3

export GENESIS_PAR_ROW

# Read parameter values
GENESIS_PAR_ROW=`lockLinuxFile $parfile dosim $parfile`;

[ "$GENESIS_PAR_ROW" == "?" ] && echo "No more parameters, ending." && exit -1;

# Run genesis 
$genexec -nox -batch -notty $genfile 

echo "Ending job"
date

