#!/bin/bash

# Extracts arguments from PBS and passes execution to sim_genesis_1par.sh.

# Modification history: 
# - Cengiz Gunay <cengique@users.sf.net> 2015/05/26
# - Amber Hudson <aehudso@emory.edu> 2014/05/28: PBS customization, error reporting.
# - Mehmet Belgin <mehmet.belgin@oit.gatech.edu> 2013/01/10: PBS customization.
# - Cengiz Gunay <cengique@users.sf.net> 2005/06/29: Initial version.

function usage()
{
   echo "Usage: "
   echo "qsub -t start-end -v genfile='genfilename',parfile='parfilename' pbs_custom.sh" 
   echo ""
   echo "E.g."
   echo "qsub -t 1-2 -v genfile='Main_cn_full_AW.g',parfile='fulltrial.par' pbs_custom.sh"
   echo ""
   echo "pbs_custom.sh is a modified version of pbs_example_template.sh that calls this "
   echo "script in its last line." 
}

function errorout() { echo "$@" 1>&2; }

cd $PBS_O_WORKDIR

if [ -z $genfile ] || [ -z $parfile ]; then
   errorout "Need to specify GENESIS script and parameter file."
   echo ""
   usage
   exit 1
fi

echo "Starting $PBS_JOBID ($PBS_JOBNAME)"
date
echo "GENESIS  script : ${genfile}"
echo "Parameter script: ${parfile}"
echo "Array ID        : ${PBS_ARRAYID}"
echo ""
echo "List of hosts: "
echo "=========================="
cat $PBS_NODEFILE
echo "=========================="

trial=$PBS_ARRAYID

exec ../param_file/sim_genesis_1par.sh
