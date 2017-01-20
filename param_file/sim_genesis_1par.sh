#! /bin/bash

function usage() {
    cat <<EOF 
This script reads a designated row from the parameter file and
executes Genesis to process it. It uses a fast hashtable lookup to
read the parameter row from a database created with the par2db.pl
script. This script is independent of PBS or SGE systems and it is
intended to be executed by SGE or PBS scripts in respective
directories.

Usage: 
${0##*/} genfile parfile trial

Input arguments:
  genfile: Genesis script (e.g., myfunc.g).
  parfile: Parameter file name (e.g., mymodel.par).
  trial: Row number to read from parameter file (e.g., 1). If missing, read from PSN_TRIAL.

Environment variables read
  PRERUN: (Optional) A script to run with the extracted parameters before
	executing Genesis (e.g., checkMissing.sh).
  PSN_TRIAL: Trial number (see above).
  PSN_PRINT: If set, print out Genesis command line instead of
  executing for making batch files.

See the corresponding scripts in the SGE and PBS directories for
submission examples (e.g., sge_sim_genesis_1par.sh and
pbs_sim_genesis_1par.sh). To choose a different Genesis binary modify
the GENESIS environment variable. Default binary is "genesis". Default
Genesis command line arguments are "-nox -batch -notty" and can be
overridden by assigning a value to the environment variable
GENESIS_ARGS.

Compatibility with older Genesis scripts: Notice that, this script
does not mark the row as processed in the original parameter
file. One needs to use checkMissing.pl script to find out which rows
are already done.  The reason this script does not modify the
parameter file is to avoid race conditions that occur when writing
to the parameter file concurrently.
EOF
}

# Modification history:
# - Cengiz Gunay <cgunay@emory.edu> 2015/05/26
#	Broke into layers to share code across cluster SGE/PBS platforms
# - Anca Doloc-Mihu <adolocm@emory.edu>, 2008/08/14
# 	Switched to lgenesis (leech-genesis)
# - Cengiz Gunay <cgunay@emory.edu> 2005/06/29
#	Original script.

[ -z "$2" ] && echo -e "Error: Missing arguments, exiting.\n" && usage && exit -1;

genfile=$1
parfile=$2
trial=${3:-${PSN_TRIAL:?"Error: Missing trial argument and PSN_TRIAL is unset, exiting.\n"}} \
    || usage;

trap exit INT

export GENESIS_PAR_ROW GENESIS_PAR_NAMES

GENESIS_PARS=`get_genesis_pars.sh $parfile $trial` 

if [ -v PSN_PRINT ]; then
    # Just print out instead of executing
    echo "$GENESIS_PARS ${GENESIS:=genesis} ${GENESIS_ARGS:=-nox -batch -notty} $genfile"
else
    eval $GENESIS_PARS
    [ -z "$GENESIS_PAR_ROW" ] && { echo "Failed to get parameters."; exit -1; }

    # if given, run prerun_script with parameters
    [ -n "$prerun" ] && ( $prerun "$GENESIS_PAR_ROW" || \
	{ echo "Failed to run $3 \"$GENESIS_PAR_ROW\""; \
	exit -1; } )

    # Run genesis 
    /usr/bin/time -f  "=== Time of simulation: elapsed = %E...kernel cpu = %S... user cpu = %U... cpu alloc = %P ====" ${GENESIS:=genesis} ${GENESIS_ARGS:=-nox -batch -notty} $genfile

    [ "$?" != "0" ] && echo "GENESIS run failed, terminating job!" && exit -1

    echo "Ending job"
    date
fi
