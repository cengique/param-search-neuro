#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash

# Need to source our own rc file. >:O
source $HOME/.bashrc

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

export GENESIS_PAR_ROW

# Random delay to avoid deadlock
#awk 'BEGIN {system("sleep " rand() * 10)}'

# Read parameter values

# Watchdog counter
count=20
until GENESIS_PAR_ROW=`ssh clust.cc.emory.edu cd run\; lockLinuxFile $parfile dosim $parfile`; || [ $count < 1 ] do 
	echo "Reading parameters... Countdown: $count"
	count=$[ $count - 1]
done

#rm -f mutex2.lock
[ "$GENESIS_PAR_ROW" == "?" ] && echo "No more parameters, ending." && exit 0;

# Run genesis 
genesis -nox -batch -notty $genfile 

echo "Ending job"
date

