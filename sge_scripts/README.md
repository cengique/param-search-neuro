<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Scripts specific to the Sun Grid Engine (SGE)](#scripts-specific-to-the-sun-grid-engine-sge)
    - [New style scripts that allow customization and refer to common scripts under `param_file/`](#new-style-scripts-that-allow-customization-and-refer-to-common-scripts-under-paramfile)
    - [Old style scripts](#old-style-scripts)
    - [Running simulations on an SGE cluster](#running-simulations-on-an-sge-cluster)
    - [Example SGE usage scenarios that can be adapted to other HPC platforms](#example-sge-usage-scenarios-that-can-be-adapted-to-other-hpc-platforms)
    - [Examples for Matlab and other simulator job submissions](#examples-for-matlab-and-other-simulator-job-submissions)
    - [Other commonly used SGE commands](#other-commonly-used-sge-commands)
    - [Cluster queue priorities](#cluster-queue-priorities)

<!-- markdown-toc end -->


# Scripts specific to the Sun/Oracle Grid Engine (SGE)

All scripts provide documentation when run without arguments. To learn
about the Sun Grid Engine (SGE) on how to submit and monitor jobs,
start from the `man sge_intro` manual page.

Use the `qsub` command to submit jobs to the SGE or PBS/MOAB.

## New style scripts that allow customization and refer to common scripts under `param_file/`
 - `sge_example_template.sh` Copy this script locally and customize.
 - `sge_sim_genesis_1par.sh` Extracts parameters from SGE variables and calls
   `../param_file/sim_genesis_1par.sh`
 - `sge_submit_genesis` Convenience script to submit an SGE array job
   for GENESIS to run _all_ rows in given parameter file.

## Old style scripts
 - `sim_exec_1par.sh` SGE script that runs any generic executable with 1 parameter line.
 - `sim_genesis.sh` SGE script that runs a GENESIS.
 - `sim_matlab.sh` SGE script that runs Matlab.
 - `sim_null.sh` Blank SGE script for testing purposes. Creates output files.

## Running simulations on an SGE cluster

First, create a parameter file (`.par`) using any method as explained
in the [param_file](../param_file) subfolder.

The _new_ method to call any simulator is:

```bash
$ qsub -t N:M my_sge_template.sh [args...]
```

where `my_sge_template.sh` is a copy of `sge_example_template.sh` that
contains your SGE environment settings and finishes with a call to a
job script like `sim_matlab.sh` or `sge_sim_genesis_1par.sh`. The
argument N:M indicates the range of rows from the parameter file to
execute (if your executable needs a parameter file). These examples
can be followed to make generic scripts for other HPC platforms.

To submit ALL parameter sets in GENESIS jobs, do:

```bash
$ ./sge_submit_genesis my_gen_script.g 5rows9pars.par [options-to-qsub]
```

which will create the db from the parameter file, and submit an array
job to SGE by calling the `sge_sim_genesis_1par.sh` for each job
during runtime.

## Example SGE usage scenarios that can be adapted to other HPC platforms

GENESIS Example with Parameter File 1:

		$ sge_submit_genesis setup_newscan.g exc-subset-simple-scan-2.par
		GENESIS script: setup_newscan.g; param. file: exc-subset-simple-scan-2.par
		with 440 trials.

		440 rows and 11 parameters in file exc-subset-simple-scan-2.par.

		Your job 22538.1-440:1 ("sge_run") has been submitted.

GENESIS Example with Parameter File 1 (by specifying cluster variables):

		$ sge_submit_genesis setup_newscan.g exc-subset-simple-scan-2.par -l immediate=TRUE

GENESIS Example by specifying a subset of parameter sets:

		$ par2db.pl my_conductances.par
		$ qsub -t 1:100 sge_sim_genesis_1par.sh my_gen_script.g my_conductances.par

GENESIS Example w/o Parameter File:

		$ qsub sim_genesis.sh my_gen_script.g

## Examples for Matlab and other simulator job submissions 

MATLAB Example 1:

		$ qsub -t 1:60 ~/scripts/sim_matlab.sh calculate(%d)

This will call the matlab functions `calculate(1), calculate(2),` ... etc. in each job.

MATLAB Example 2:

		$ qsub -t 1:60 ~/scripts/sim_matlab.sh load_part%d

This will call `load_part1, load_part2, ..., load_part60` in each matlab process.

Any executable with Parameter File:

		$ par2db.pl my_conductances.par
		$ qsub -t 1:100 ~/scripts/sim_exec_1par.sh myexec my_conductances.par


## Other commonly used SGE commands

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

## Cluster queue priorities

		$ qsub -p <priority> ...

will specify that the priority of the current job. 

Priority convention for the fast_run queue:

		Job time	Priority
		------------------------
		<1hr		0
		1-5 hrs		-100
		5-24 hrs	-200
		> 24 hrs	not appropriate for fast_run 
