# Copy this file and customize it for your cluster and jobs
#PBS -q tardis-6
#PBS -l nodes=1:ppn=64
#PBS -l pmem=1gb,mem=64gb
#PBS -l walltime=10:00:00
#PBS -j oe
#PBS -o Matlab.output.$PBS_JOBID

# Then pass the execution to one of the scripts in this directory.
exec ~/work/brute-scripts/moab_scripts/moab_matlab.sh
