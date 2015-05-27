# Copy this file and customize it for your cluster and jobs

# Example PBS directives. Modify as necessary:
#PBS -N my_testrun
#PBS -q tardis-6
#PBS -l nodes=1:ppn=64
#PBS -l pmem=1gb,mem=64gb
#PBS -l walltime=10:00:00
#PBS -j oe
#PBS -o Matlab.output.$PBS_JOBID
#PBS -m abe
#PBS -M my@email.com

# Change default search path
export PATH=mypath:$PATH

# Change to workdir
cd $PBS_O_WORKDIR

# Then pass the execution to one of the scripts in this directory.
exec pbs_matlab.sh
