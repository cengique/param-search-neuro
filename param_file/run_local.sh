#! /bin/bash

# Runs a range of parameter trials locally by calling sim_* scripts.

if [ -z "$2" ]; then
   echo "$0: Runs a parameter set locally by calling a sim_* script."
   echo "Error: Missing arguments."
   echo ""
   echo "Usage: "
   echo "   ${0##*/} row_range sim_script [args...]"
   echo 
   echo " row_range: Parameter row range (X:Y) to process."
   echo " sim_script [args...]: Script to call with arguments after setting PSN_TRIAL (e.g. sim_genesis_1par.sh)."
   echo 
   exit -1
fi

trap exit INT

par_range=$1
shift

function receive_range {
    row_start=$1
    row_end=$2
    num_rows=$3
}

RANGES=`read_ranges.sh $par_range`
[ "$?" != "0" ] && >&2 echo "Parameter range parsing failed." && exit -1

receive_range $RANGES

# Run it repeatedly
export PSN_TRIAL
echo "Starting run from $row_start to $row_end"
for (( i = $row_start; i <= $row_end; i = $[ $i + 1 ] )); do 
    echo "Running #$i"
    PSN_TRIAL=$i
    $*
done
