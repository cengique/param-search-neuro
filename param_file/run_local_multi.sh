#! /bin/bash

if [ -z "$3" ]; then
   echo "Error: Missing arguments."
   echo ""
   echo "$0: Runs a parameter set locally on separate parallel thread by"
   echo "splitting the job between multiple sge_local.sh runs. Outputs will "
   echo "be written to files named as '<sim_script>-X.out', where X is 1..N."
   echo
   echo "Usage: "
   echo "   $0 N row_range sim_script [args...]"
   echo 
   echo " N: Number of parallel threads"
   echo " row_range: Parameter row range (X:Y) to process."
   echo " sim_script [args...]: Script to call with arguments after setting SGE_TASK_ID."
   echo 
   exit -1
fi

trap exit INT

num_threads=$1
shift

par_range=$1
shift

sim_script=$1

echo "$par_range" | grep -qE '[0-9]+:[0-9]+' || \
    ( echo "Error: Row range not recognized: $par_range" && exit -1 )

row_start=`echo "$par_range" | sed -e 's/\([0-9]\+\):[0-9]\+/\1/'`
row_end=`echo "$par_range" | sed -e 's/[0-9]\+:\([0-9]\+\)/\1/'`
num_rows=$[ $row_end - $row_start + 1 ]

# Divide and run in the background
echo "Starting $num_threads parallel sge_local.sh jobs."
for (( i = 0; i < $num_threads; i = $[ $i + 1 ] )); do 
    this_start=$[ $row_start + $i * $num_rows / $num_threads]
    this_end=$[ $row_start + ($i + 1) * $num_rows / $num_threads - 1]
    echo "Running thread #$i with rows ${this_start}:$this_end"
    sge_local.sh ${this_start}:$this_end $* &> $sim_script-$i.out &
done

echo "Waiting for jobs to finish..."
wait
echo "Done."