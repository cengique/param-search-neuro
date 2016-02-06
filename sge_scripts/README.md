## Scripts specific to the Sun Grid Engine (SGE)

### New style scripts that allow customization and refer to common scripts under `param_file/`
 - `sge_example_template.sh` Copy this script locally and customize.
 - `sge_sim_genesis_1par.sh` Extracts parameters from SGE and calls `../param_file/sim_genesis_1par.sh`

### Old style scripts
 - `sge_submit` Submits SGE jobs based on given parameter file.
 - `sge_local.sh` Locally runs an array job of one of the below sim_* scripts.
 - `sge_local_multi.sh` Locally runs sge_local.sh by splitting the array into multiple threads.
 - `sim_exec_1par.sh` SGE script that runs a generic executable with 1 parameter line.
 - `sim_genesis.sh` SGE script that runs a Genesis.
 - `sim_matlab.sh` SGE script that runs Matlab.
 - `sim_null.sh` Blank SGE script for testing purposes. Creates output files.

Commonly used SGE commands
----------------------------------------

		$ qcountcpus
		
will give you a list of queues and the number of CPUs currently available in each.

		$ qstat
		
will give you a list of all scheduled jobs on the cluster.

		$ qstat | grep yourusername
		
will only show the lines with your jobs.

		$ qstat -f
		
will show the status of all nodes on the cluster.

		$ qstat -j jobnumber
		
will give you detailed info about your job, including error messages.

		$ qmod -cj jobnumber
		
will clear the error state of a job and let it re-run.

Cluster queue priorities
----------------------------------------

		$ qsub -p <priority> ...

will specify that the priority of the current job. 

Priority convention for the fast_run queue:

		Job time	Priority
		------------------------
		<1hr		0
		1-5 hrs		-100
		5-24 hrs	-200
		> 24 hrs	not appropriate for fast_run 
