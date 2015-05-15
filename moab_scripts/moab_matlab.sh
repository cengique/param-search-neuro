# MOAB script for submitting an arbitrary Matlab job
#
# Example usage: 
# matlab_cmd="setup(),myfunc(1,2,3)" qsub -q queue-name -v matlab_cmd moab_matlab.sh
# (Note that you need to escape special characters in matlab_cmd)
#
# Adapted from Georgia Institute of Technology PACE cluster manuals.
# Author: Cengiz Gunay <cengique@users.sf.net>, 2015-05-13

# Modify the following for your cluster:
#PBS -q tardis-6
#PBS -l nodes=1:ppn=64
#PBS -l pmem=1gb,mem=64gb
#PBS -l walltime=10:00:00
#PBS -j oe
#PBS -o Matlab.output.$PBS_JOBID

cd $PBS_O_WORKDIR

# Create the tmp directory for matlab parallel
RUNDIR=~/scratch/simhe/jobID_$PBS_JOBID/

# Required variables
if [ -z "$matlab_cmd" ]; then
  echo "matlab_cmd is a required environment variable. "
  echo "Set it with the -v option to qsub."
  exit -1
fi

# Run Matlab (remove the setup step if you don't have this)
matlab -singleCompThread -r "moab_setup('$RUNDIR'); $matlab_cmd"
echo "Finished Matlab"

# Remove directory
rm -rf $RUNDIR
echo "Deleted $RUNDIR"
