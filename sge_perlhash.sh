#! /bin/bash

#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash

# The following skips work46 because of Perl DB_File problems
## -q all.q@work01,all.q@work02,all.q@work03,all.q@work04,all.q@work05,all.q@work06,all.q@work07,all.q@work08,all.q@work09,all.q@work10,all.q@work11,all.q@work12,all.q@work13,all.q@work14,all.q@work15,all.q@work16,all.q@work17,all.q@work18,all.q@work19,all.q@work20,all.q@work25,all.q@work26,all.q@work27,all.q@work28,all.q@work29,all.q@work30,all.q@work31,all.q@work32,all.q@work33,all.q@work34,all.q@work35,all.q@work36,all.q@work37,all.q@work38,all.q@work39,all.q@work40,all.q@work41,all.q@work42,all.q@work43,all.q@work44,all.q@work45,all.q@work46,all.q@work47,all.q@work48,all.q@work49,all.q@work50,all.q@work51,all.q@work52,all.q@work53,all.q@work54,all.q@work55,all.q@work56,all.q@work57,all.q@work58,all.q@work59,all.q@work60,all.q@work61,all.q@work62

# This sge job script reads a designated row from the parameter file and executes
# genesis to process it. It uses a fast hashtable access to read the parameter 
# row from a database created with the create_perlhash_param_db script.
# Notice that, this script does not mark the row as processed in the original 
# parameter file. One needs to use checkMissing.pl script to find out which 
# rows are already done.
# The reason this script does not modify the parameter file is to avoid
# race conditions that occur when writing to the parameter file concurrently.

# Author: Cengiz Gunay <cgunay@emory.edu> 2005/06/29
# $Id: sge_perlhash.sh,v 1.4 2006/02/27 16:47:46 cengiz Exp $

# Run this with:
# qsub -t 1:1310 ~/brute_scripts/sge_perlhash.sh setup_cip_act_handtune.g blocked_gps0501-03_2.par

# Need to source our own rc file. >:O
source $HOME/.bashrc

curdir=`pwd`

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST from parameter file $2 at $HOSTNAME on "
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

# Special check for cluster traps
#if [ $HOSTNAME == "work46" ]; then 
#	echo "I don't like work46, it doesn't have the perl libraries I need. I'm going to take a nap now."
#	sleep $[60 * 60 * 24 * 3]	# Sleep for 3 days
#	exit -1
#fi

export GENESIS_PAR_ROW

# Random delay to avoid deadlock only for the first batch of nodes
# Afterwards, the offsets should be preserved.
if [[ $SGE_TASK_ID < 126 ]]; then
   awk 'BEGIN {system("sleep " rand() * 20)}'
fi

# Read parameter values.
GENESIS_PAR_ROW=`dosimnum $parfile $SGE_TASK_ID`

[ "$?" != "0" ] && echo "Cannot read parameter row $SGE_TASK_ID, ending." && exit -1;

# Run genesis 
time genesis -nox -batch -notty $genfile

[ "$?" != "0" ] && echo "GENESIS run failed, terminating job!" && exit -1

echo "Ending job"
date

