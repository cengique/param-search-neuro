#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash
#$ -o sge_run/$HOSTNAME

# This SGE job script reads a designated row from the parameter file and executes
# genesis to process it. It uses a fast hashtable access to read the parameter 
# row from a database created with the create_perlhash_param_db script.
# Notice that, this script does not mark the row as processed in the original 
# parameter file. One needs to use checkMissing.pl script to find out which 
# rows are already done.
# The reason this script does not modify the parameter file is to avoid
# race conditions that occur when writing to the parameter file concurrently.

# To choose a different Genesis binary modify the $GENESIS environment variable.

# Author: Cengiz Gunay <cgunay@emory.edu> 2005/06/29
# $Id: sge_perlhash.sh,v 1.4 2006/02/27 16:47:46 cengiz Exp $

# Modified by Anca Doloc-Mihu <adolocm@emory.edu>, 2008/08/14
# switched to lgenesis (leech-genesis)

# Example:
# qsub -t 1:1310 ~/brute_scripts/sge_perlhash.sh setup_cip_act_handtune.g blocked_gps0501-03_2.par

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

# Default value is genesis
${GENESIS:=genesis}

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST from parameter file $2 on $HOSTNAME at "
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

# Read parameter values.
GENESIS_PAR_ROW=`dosimnum $parfile $SGE_TASK_ID`

[ "$?" != "0" ] && echo "Cannot read parameter row $SGE_TASK_ID, ending." && exit -1;

# Run genesis 
/usr/bin/time -f  "=== Time of simulation: elapsed = %E...kernel cpu = %S... user cpu = %U... cpu alloc = %P ====" $GENESIS -nox -batch -notty $genfile

[ "$?" != "0" ] && echo "GENESIS run failed, terminating job!" && exit -1

echo "Ending job"
date


