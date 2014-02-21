#! /bin/bash

# Need to source our own rc file. 
source $HOME/.bashrc

echo "Starting job $SGE_TASK_ID/$SGE_TASK_LAST on $HOSTNAME"
date

if [ -z "$1" ]; then
   echo "Need to specify GENESIS script."
   echo ""
   echo "Usage: "
   echo "   $0 genesis_script"
   exit -1
fi

genfile=$1

# Run genesis
genesis -nox -batch -notty $genfile

echo "Ending job"
date


