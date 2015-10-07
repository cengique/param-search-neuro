#!/bin/bash

# Extracts arguments from PBS and passes execution to
# sim_genesis_1par.sh, which needs to be on the search PATH.

# Modification history: 
# - Cengiz Gunay <cengique@users.sf.net>
#   - 2015/10/06 - adapt PBS script to SLURM
#   - 2015/05/26
# - Amber Hudson <aehudso@emory.edu> 2014/05/28: PBS customization, error reporting.
# - Mehmet Belgin <mehmet.belgin@oit.gatech.edu> 2013/01/10: PBS customization.
# - Cengiz Gunay <cengique@users.sf.net> 2005/06/29: Initial version.

function usage()
{
   echo "Usage: "
   echo "sbatch -a start-end slurm_custom.sh genfilename parfilename" 
   echo ""
   echo "E.g."
   echo "sbatch -a 1-2 slurm_custom.sh Main_cn_full_AW.g fulltrial.par"
   echo ""
   echo "slurm_custom.sh is a modified version of slurm_example_template.sh"
   echo "that calls this script in its last line." 
}

function errorout() { echo "$@" 1>&2; }

cd $SLURM_SUBMIT_DIR

genfile=$1
parfile=$2

if [ -z $genfile ] || [ -z $parfile ]; then
   errorout "Need to specify GENESIS script and parameter file."
   echo ""
   usage
   exit 1
fi

echo "Starting $SLURM_JOB_ID ($SLURM_JOB_NAME)"
date
echo "GENESIS  script : ${genfile}"
echo "Parameter script: ${parfile}"
echo "Array ID        : ${SLURM_ARRAY_TASK_ID}"
echo ""
echo "List of hosts: "
echo "=========================="
cat $SLURM_JOB_NODELIST
echo "=========================="

source sim_genesis_1par.sh $genfile $parfile $PBS_ARRAYID
