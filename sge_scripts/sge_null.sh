#! /bin/bash

# Should be called from your custom SGE script. See sge_example_template.

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST on $HOSTNAME at "
date

trap exit INT

echo "Ending job"
date

