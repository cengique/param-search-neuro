# MOAB/PBS script for submitting an arbitrary Matlab job
#
# Example usage: 
# matlab_cmd="setup(),myfunc(1,2,3)" qsub -v matlab_cmd pbs_custom.sh
#
# (Note that you need to escape special characters in
# matlab_cmd. pbs_custom.sh is modified from pbs_example_template.sh.)
#
# It is better to make a separate local script to add your PBS
# directives and then simply exec this script at the end of it.
# 
# Adapted from Georgia Institute of Technology PACE cluster manuals.
# Author: Cengiz Gunay <cengique@users.sf.net>, 2015-05-13

# Create the tmp directory for matlab parallel
RUNDIR=~/scratch/simhe/jobID_$PBS_JOBID/

# Required variables
if [ -z "$matlab_cmd" ]; then
  echo "matlab_cmd is a required environment variable. "
  echo "Set it with the -v option to qsub."
  exit -1
fi

echo "Running Matlab command line:"
echo "$matlab_cmd"

# Run Matlab (remove the setup step if you don't have this)
/usr/bin/time -f  "=== Run time: elapsed= %E...kernel cpu= %S... user cpu= %U... cpu alloc= %P ====" \
matlab -singleCompThread -r "moab_setup('$RUNDIR'); $matlab_cmd"
echo "Finished Matlab"

# Remove directory
rm -rf $RUNDIR
echo "Deleted $RUNDIR"
