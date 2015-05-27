
# Extracts arguments from SGE and passes execution to sim_genesis_1par.sh.
# Run without parameters to see usage example

# Modification history: 
# - Cengiz Gunay <cengique@users.sf.net> 2015/05/26: Collected SGE-related pieces 
# from other scripts.

echo -n "Starting job $SGE_TASK_ID/$SGE_TASK_LAST from parameter file $2 on $HOSTNAME at "
date

if [ -z "$2" ]; then
   echo "Need to specify GENESIS script and parameter file."
   echo ""
   echo "Direct usage: "
   echo "   $0 genesis_script parameter_file [prerun_script]"
   echo 
   echo "prerun_script - If specified, this script is run and "
   echo "passed the parameters that were read."
   echo 
   echo "Cluster submission:"
   echo "qsub -t 1:1310 sge_custom.sh setup_cip_act_handtune.g blocked_gps0501-03_2.par"
   echo 
   echo "sge_custom.sh is a modified version of sge_example_template.sh that calls this "
   echo "script in its last line." 
   exit -1
fi

genfile=$1
parfile=$2
trial=$SGE_TASK_ID

exec ../param_file/sim_genesis_1par.sh
