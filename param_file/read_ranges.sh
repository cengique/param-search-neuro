#! /bin/bash

function usage() {
    cat <<EOF 

This script parses a range of trials in the form of "X:Y" to extract
the values of X and Y. It returns the start, end, and number of rows
separated by spaces.

Usage: 
${0##*/} trial_range

Input arguments:
  trial_range: Range of trials to read from parameter file (e.g.,
  	1:100) or name of parameter file to select all trials will be
  	selected.
EOF
}

[ -z "$1" ] && { >&2 echo "Missing arguments!"; usage; exit -1; }

par_range="$1"

# if it includes a ':' character, then it's a range. 
if ( echo "$par_range" | grep -qE '[0-9]+:[0-9]+' ); then
    row_start=`echo "$par_range" | sed -e 's/\([0-9]\+\):[0-9]\+/\1/'`
    row_end=`echo "$par_range" | sed -e 's/[0-9]\+:\([0-9]\+\)/\1/'`
    num_rows=$[ $row_end - $row_start + 1 ]
else # otherwise it's parameter file
    parfile=$par_range

    [ ! -r $parfile ] && \
	{ >&2 echo "Error: Row range or parameter file not recognized: $par_range" && exit -1; }

    # Select all rows
    row_start=1
    row_end=$(( `wc -l $parfile | cut -f1 -d\ ` - 1 ))
    num_rows=$row_end
fi

[ $row_start -gt $row_end ] && \
    { >&2 echo "Error: Row start cannot be higher than row_end: $par_range" && exit -1; }

echo "$row_start $row_end $num_rows"
