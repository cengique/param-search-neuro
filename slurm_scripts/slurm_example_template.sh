#!/bin/bash

# Copy this file and customize it for your cluster and jobs

# Example PBS directives. Modify as necessary:
#SBATCH --job-name="my_testrun"
#SBATCH --output="Matlab.output.%j.%N"
#SBATCH --partition=compute
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --export=ALL
#SBATCH -t 01:30:00

# Change default search path
export PATH=mypath:$PATH

# Then pass the execution to one of the scripts in this directory.
exec pbs_matlab.sh
