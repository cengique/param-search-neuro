#! /bin/bash

# Runs a parameter set locally by calling an SGE sim_* script.

if [ -z "$2" ]; then
   echo "$0: Runs a parameter set locally by calling an SGE sim_* script."
   echo "Error: Missing arguments."
   echo ""
   echo "Usage: "
   echo "   $0 row_range sim_script [args...]"
   echo 
   echo " row_range: Parameter row range (X:Y) to process."
   echo " sim_script [args...]: Script to call with arguments after setting SGE_TASK_ID (e.g. sim_genesis_1par.sh)."
   echo 
   exit -1
fi

trap exit INT

par_range=$1
shift

echo "$par_range" | grep -qE '[0-9]+:[0-9]+' || \
    ( echo "Error: Row range not recognized: $par_range" && exit -1 )

row_start=`echo "$par_range" | sed -e 's/\([0-9]\+\):[0-9]\+/\1/'`
row_end=`echo "$par_range" | sed -e 's/[0-9]\+:\([0-9]\+\)/\1/'`

# TODO: parameterize genesis script and parameter file
#parfile=`grep '\.par' $par_range | sed -e 's/^.*"\(.*\)"/\1/'`

#echo "Parfile: $parfile"

# Get the number of trials from the parameter file
#trials=`awk 'BEGIN{ getline; print $par_range}' < $parfile`

# Run it repeatedly
export SGE_TASK_ID
echo "Starting run from $row_start to $row_end"
for (( i = $row_start; i <= $row_end; i = $[ $i + 1 ] )); do 
    echo "Running #$i"
    SGE_TASK_ID=$i
    $*
done
