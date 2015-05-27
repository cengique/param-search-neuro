#! /bin/bash

# This script reads a designated row from the parameter file and
# executes genesis to process it. It uses a fast hashtable lookup to
# read the parameter row from a database created with the par2db.pl
# script. This script is independent of PBS or SGE systems and it is
# intended to be executed by SGE or PBS scripts in respective
# directories.
#
# Input parameters are provided via environment variables:
#   genfile: Genesis script (e.g., myfunc.g).
#   parfile: Parameter file name (e.g., mymodel.par).
#   trial: Row number to read from parameter file (e.g., 1).
#   prerun: (Optional) A script to run with the extracted parameters before
#	executing Genesis (e.g., checkMissing.sh).
#
# See the corresponding scripts in the SGE and PBS directories for submission examples (e.g., sge_sim_genesis_1par.sh and pbs_sim_genesis_1par.sh)
# To choose a different Genesis binary modify the GENESIS environment variable. 
# Default binary is "genesis".
#
# Compatibility with older Genesis scripts: Notice that, this script
# does not mark the row as processed in the original parameter
# file. One needs to use checkMissing.pl script to find out which rows
# are already done.  The reason this script does not modify the
# parameter file is to avoid race conditions that occur when writing
# to the parameter file concurrently.

# Modification history:
# - Cengiz Gunay <cgunay@emory.edu> 2015/05/26
#	Broke into layers to share code across cluster SGE/PBS platforms
# - Anca Doloc-Mihu <adolocm@emory.edu>, 2008/08/14
# 	Switched to lgenesis (leech-genesis)
# - Cengiz Gunay <cgunay@emory.edu> 2005/06/29
#	Original script.

trap exit INT

export GENESIS_PAR_ROW GENESIS_PAR_NAMES

# Read parameter values and names.
GENESIS_PAR_ROW=`get_1par.pl $parfile $trial`
GENESIS_PAR_NAMES=`awk '{ printf $0 " "}' < ${parfile%.par}.txt`

[ "$?" != "0" ] && echo "Cannot read parameter row $trial, ending." && exit -1;

# if given, run prerun_script with parameters
[ -n "$prerun" ] && ( $prerun "$GENESIS_PAR_ROW" || \
    ( echo "Failed to run $3 \"$GENESIS_PAR_ROW\"" && \
      exit -1; ) )

# Run genesis 
/usr/bin/time -f  "=== Time of simulation: elapsed = %E...kernel cpu = %S... user cpu = %U... cpu alloc = %P ====" ${GENESIS:=genesis} -nox -batch -notty $genfile

[ "$?" != "0" ] && echo "GENESIS run failed, terminating job!" && exit -1

echo "Ending job"
date
