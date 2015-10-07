#! /bin/bash

# Should be called from your custom SLURM script. See slurm_example_template.sh

echo -n "Starting job $SLURM_ARRAY_TASK_ID on $SLURM_NODENAME at "
date

trap exit INT

echo "Ending job"
date

