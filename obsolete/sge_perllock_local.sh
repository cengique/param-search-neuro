#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash

# Run this with:
# qsub -t 1:1310 ~/brute_scripts/sge_perllock.sh setup_cip_act_handtune.g blocked_gps0501-03_2.par

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

echo "Starting job $SGE_TASK_ID/$SGE_TASK_LAST on $HOSTNAME"
date

if [ -z "$2" ]; then
   echo "Need to specify GENESIS script and parameter file."
   echo ""
   echo "Usage: "
   echo "   $0 genesis_script parameter_file"
   exit -1
fi

trap exit INT

genfile=$1
parfile=$2

# Random delay to avoid deadlock
awk 'BEGIN {system("sleep " rand() * 20)}'

export GENESIS_PAR_ROW

# Read parameter values.
GENESIS_PAR_ROW=`lockLinuxFile $parfile dosim $parfile`

[[ $? != 0 ]] && echo "Error: Cannot read parameter row from $parfile, ending." && exit -1

[ "$GENESIS_PAR_ROW" == "?" ] && echo "No more parameters, ending." && exit 0

# Run genesis 
genesis -nox -batch -notty $genfile 

echo "Ending job"
date

