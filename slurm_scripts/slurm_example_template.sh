#!/bin/bash

# Copy this file and customize it for your cluster and jobs

# Example PBS directives. Modify as necessary:
#SBATCH --job-name="my_testrun"
#SBATCH --output="Null.output.%j.%N"
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --export=ALL
#SBATCH -t 01:30:00

# Change default search path
export PATH=~cgunay/param-search-neuro/slurm_scripts:$PATH

# Then pass the execution to one of the scripts in this directory.
exec slurm_array_null.sh
