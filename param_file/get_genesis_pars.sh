#! /bin/bash

function usage() {
    cat <<EOF 

This script is called from sim_genesis_1par.sh to load the parameter
names and values into shell environment variables. It returns a string
that sets those variables when evaluated.

Usage: 
${0##*/} parfile trial

Input arguments:
  parfile: Parameter file name (e.g., mymodel.par).
  trial: Row number to read from parameter file (e.g., 1).

See sim_genesis_1par.sh for more information.
EOF
}

[ -z "$2" ] && >&2 echo -e "Error: Missing arguments, exiting.\n" && usage && exit -1

parfile=$1
trial=$2

# Sanity check
[ -r $parfile ] || { >&2 echo "Cannot find parameter file $parfile"; exit -1; }

# Check parameter DB and, if not exists, create it. 
[ -r "${parfile}.db" ] || { 
    echo "Creating missing database file from parameter file $parfile."
    par2db.pl ${parfile} 
}

# Read parameter values and names.
GENESIS_PAR_ROW=`get_1par.pl $parfile $trial`
[ "$?" != "0" ] && >&2 echo "Cannot read parameter row $trial, ending." && exit -1

if [ -r ${parfile%.par}.txt ]; then
    GENESIS_PAR_NAMES=`awk '{ printf $1 " "}' < ${parfile%.par}.txt`
else
    >&2 echo "Cannot read parameter names from file ${parfile%.par}.txt, leaving empty."
fi

echo "GENESIS_PAR_ROW=\"$GENESIS_PAR_ROW\" GENESIS_PAR_NAMES=\"$GENESIS_PAR_NAMES\""
