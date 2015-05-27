# Copy this file and customize it for your cluster and jobs

# Example SGE directives. Modify as necessary:
#$ -cwd
#$ -j y
#$ -N sge_run
#$ -S /bin/bash
#$ -o sge_run/$HOSTNAME

# Set, change directories (redundant with -cwd directive above)
curdir=`pwd`

# If necessary, source rc file
source $HOME/.bashrc

# Then pass the execution to one of the scripts in this directory.
exec sge_sim_matlab.sh
