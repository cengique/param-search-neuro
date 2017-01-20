#! /bin/bash

function usage() {
    cat <<EOF 

This script parses a range of trials in the form of "X:Y" to extract
the values of X and Y. It returns the start, end, and number of rows
separated by spaces.

Usage: 
${0##*/} trial_range > batch_file.sh

Input arguments:
  trial_range: (Optional) Range of trials to read from parameter file
  	(e.g., 1:100). If missing, all trials will be selected.
EOF
}

par_range="$1"; shift

echo "$par_range" | grep -qE '[0-9]+:[0-9]+' || \
    { >&2 echo "Error: Row range not recognized: $par_range" && exit -1; }

row_start=`echo "$par_range" | sed -e 's/\([0-9]\+\):[0-9]\+/\1/'`
row_end=`echo "$par_range" | sed -e 's/[0-9]\+:\([0-9]\+\)/\1/'`
num_rows=$[ $row_end - $row_start + 1 ]

echo "$row_start $row_end $num_rows"
