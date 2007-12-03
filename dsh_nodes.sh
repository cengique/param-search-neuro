#! /bin/bash

if [ -z "$2" ]; then
  echo "Usage: $0 queue_string commands..."
  echo
  echo "Runs the given commands in all nodes that are part of the queues matching queue_string."
  echo "Example: $0 gen.q ls"
  echo "  	runs "ls" in all gen.q nodes."
fi

# use $1 to filter output of qstat
nodes=`qstat -f | grep $1 | grep -v aA | sed -e 's/.*\(work[0-9]*\).*/\1/' | awk '{printf $1 ","} END {print}' | sort -u`
shift	# remove $1

if [ -n "$1" ]; then
  dsh -w $nodes "$@"
fi
