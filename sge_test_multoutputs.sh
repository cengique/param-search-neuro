#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash
#$ -o sge_run/$TASK_ID

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST on $HOSTNAME at "
date

trap exit INT

echo "Ending job"
date

