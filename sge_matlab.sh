#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash
#$ -v BASH_ENV=

# This sge job script executes matlab to read a designated script.
# 
# Usage: 
#   qsub -t 1:10 .../brute_scripts/sge_matlab.sh "a=%d; my_matlab_command"
#
# Parameters:
#   matlab_command: A matlab command to run. If it contains a '%d'
#	it will be replaced with the index of the current job.
#
# Description:
#
# Author: Cengiz Gunay <cgunay@emory.edu> 2005/11/29
# $Id: sge_matlab.sh,v 1.4 2006/02/25 00:32:59 cengiz Exp $

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST on $HOSTNAME at "
date

if [ -z "$1" ]; then
   echo "Need to specify Matlab script."
   echo ""
   echo "Usage: "
   echo "   qsub [-t 1:n] $0 matlab_command"
   echo 
   echo "matlab_command: Command to run in each job. If contains a '%d', "
   echo "		it is replaced with the job index."
   exit -1
fi

trap exit INT

matscript=`printf "$*" $SGE_TASK_ID`

echo "Running matlab command: \"$matscript\""

export GENESIS_PAR_ROW

# Random delay to avoid deadlock only for the first batch of nodes
# Afterwards, the offsets should be preserved.
if [[ $SGE_TASK_ID < 126 ]]; then
   awk 'BEGIN {system("sleep " rand() * 20)}'
fi

# Run Matlab
# (if wanted, this can be added, too:  -logfile sge_matlab.o$JOB_ID.$SGE_TASK_ID)
time matlab -nodesktop -nosplash -r "$matscript" -nodisplay -nojvm


[ "$?" != "0" ] && echo "Matlab run failed, terminating job!" && exit -1

echo -n "Ending job on "
date

