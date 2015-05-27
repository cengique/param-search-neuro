Parallel parameter search scripts for simulating neuron models
======================================================================


Directory organization
----------------------------------------

* `param_file/`: Common scripts for running simulations and for maintaining parameter files.
* `pbs_scripts/`: Scripts specific to PBS/[Moab](http://www.adaptivecomputing.com/).
* `sge_scripts/`: Scripts specific to the Sun Grid Engine (SGE).
* `maintenance/`: Miscellaneous cluster and file maintenance scripts.
* `obsolete/`: Scripts no longer used. 

Subdirectories contain additional documentation.

### Tutorial Contents:

1. Introduction
2. Parameter search tutorial
3. Other command usage examples
4. Commonly used SGE commands
5. Cluster queue priorities

1. Introduction
---------

This tutorial demonstrates how to run a set of simulations on a high-performance cluster based on a parameter set. Commands and examples are given for running neuron simulations in [GENESIS](http://www.genesis-sim.org) and for cluster schedulers SGE and PBS/MOAB. However, the workflow and common scripts provide a general method, and could be adapted to other platforms.

Before running simulations on a cluster, you must first make some preparation. This
tutorial explains how to do these preparations step by step. The files
needed for them are included in this directory and explained at each
step.

To learn about the Sun Grid Engine (SGE) on how to submit 
and monitor jobs, start from the "man sge_intro" manual page. 

Use the "qsub" command to submit jobs to the SGE or PBS/MOAB.

To use these scripts, either add the paths `param_file/` and your cluster-specific script directory (e.g., `pbs_scripts`) in your search PATH, or refer to these scripts with full paths.

2. Parameter search tutorial
-----------------

This setting is for simulations run on clusters, for which we give the
parameters of the model outside the model in an ASCII input file, in a
very convenient format (4 formats accepted at this time). This input
file is transformed into another file containing all the possible
parameter combinations, with each combination on one line. Further,
each line will furnish input parameters for each simulation.


### Steps for running simulations on local machine.

1. Prepare an ASCII file `input_ASCII_file.txt` (here, called `paramLists.txt`) that contains your input data. 

 Format for this file (each line is read in a param):
 
 1. Additive increments

			param_name range_low range_high num_steps

 2. Multiplicative increments

			param_name base_val *mul_factor ^num_steps

 3. Choose from a list

			param_name [ val1 val2 ... ]

 4. Independent counter (indicates trial number)

			param_name start_val ++ [increment]
			
	and, the last line is standard: `trial 1 ++`

	E.g, for LEECH the paramLista.txt looks like this (option 3, list):

		eLeak [ -0.065 -0.055 -0.050 -0.040 -0.030 ]
		gBar1 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar2 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar3 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar4 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar5 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar6 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar7 [ 0 -0.3 -0.6 0.2 0.4 ]
		trial 1 ++

2. Obtain parameter file containing all combinations of the parameters from the input file (from 1, above).For this, use command:

			$ ./def2par.pl name_param_file < input_ASCII_file.txt

	E.g.:

			$ ./def2par.pl all_sim_comb < paramLists.txt

	will create `all_sim_comb.par` file which contains on each line a combination of the (model) parameters.
	
	*Note*: The Perl script file paramScanSingle.pl reads the `input_ASCII_file.txt` and creates the parameter combinations file `all_sim_comb.par`. The first line of this file contains the number of combinations (or, number of lines in the file, equivalent to the number of simulations) and the (number of parameters + 1). The rest of the lines are all the same: "list of parameters no_of_line 0". E.g. (first 5 lines of the `all_sim_comb.par` file):

		390625 9
		-0.065 0 0 0 0 0 0 0 1 0
		-0.055 0 0 0 0 0 0 0 2 0
		-0.050 0 0 0 0 0 0 0 3 0
		-0.040 0 0 0 0 0 0 0 4 0
		-0.030 0 0 0 0 0 0 0 5 0
	
	*Note*: you can find the usage of the perl script by typing:

		$ ./def2par.pl


3. Create a db that is a hashtable for the simulations:

		$ ./par2db.pl all_sim_comb.par 

	The output of the command is `all_sim_comb.par.db` (`*.par.db`) file which is a database (db) containing a hashtable. This db provides fast access to a simulation based on its hash key from the hashtable (reading its corresponding line from the parameter file is a much slower way of accessing it).

	*Note*: The db file is a very large file. So, before creating it, one needs to make sure there is enough space on the disk.

	*Note*: You can access data from the database by using dosimnum script:

		$ ./get_1par.pl    //gives the usage of the command

	 For accessing line 8 (the 8th combination of param) of the all_sim_comb.par.db db:

		$ ./get_1par.pl param_file line_no //general syntax

   e.g.:

		$ ./get_1par.pl all_sim_comb.par 8

4. Use Genesis environment variables to set the row no. (obtained via db) to be passed as input param to the genesis file:

		$ export GENESIS_PAR_ROW=`path/get_1par.pl param_file line_no`   //general syntax
	
	E.g.:

		$ export GENESIS_PAR_ROW=`~/scripts/get_1par.pl all_sim_comb.par 8`


5. Finally, ready to run a simulation on local machine (here, for LEECH):

		$ time lgenesis -nox -batch -notty genesis_script 2>&1 

	E.g.:

		$ time lgenesis -nox -batch -notty mainSimScript_ElementalOscillator.g 2>&1 

	*Note*: For LEECH, `mainSimScript_ElementalOscillator.g` was modified from its original version (`testarray.g`, done by Adam Weaver) to accept the simulation parameters from outside (as explained above, from the initial input ASCII file, `paramLists.txt`). 


### Steps for running simulations on cluster nodes.

1. Performs steps (1)-(3) from above. To run the cluster scripts you need to have them (`sge_submit` and `sim_genesis_1par.sh`), and the following data:

	- `input_ASCII_file.txt` (e.g., `paramLists.txt`)
	- param_file (e.g., `all_sim_comb.par`) - created as above
    Also, make sure you have enough space for the db.

2. Submit jobs to cluster nodes:

		$ ./sge_submit    //gives general info on how to run the script

	E.g., run in the script directory:

		$ ./sge_submit  mainSimScript_ElementalOscillator.g all_sim_comb.par [options-to-qsub]

	The `sge_submit`:

	- creates the db from the `param_file`
	- submits to a specific cluster node a specific simulation (according to its line number); For this, it calls `sim_genesis_1par.sh` script with `your_genesis_script_to_run` and `param_file`.

	The `sim_genesis_1par.sh`:

	- sources your bash startup script
	- set up the current directory for the simulation
	- sets up a Genesis environment variable to a specific row no.
	- finally, runs simulation by passing this variable as param to `your_genesis_script` (here, `mainSimScript_ElementalOscillator.g`)


2. Other command usage examples
----------------------------------------

GENESIS Example with Parameter File 1:

		$ sge_submit setup_newscan.g exc-subset-simple-scan-2.par
		GENESIS script: setup_newscan.g; param. file: exc-subset-simple-scan-2.par
		with 440 trials.

		440 rows and 11 parameters in file exc-subset-simple-scan-2.par.

		Your job 22538.1-440:1 ("sge_run") has been submitted.

GENESIS Example with Parameter File 1 (using the fast-run queue):

		$ sge_submit setup_newscan.g exc-subset-simple-scan-2.par -l immediate=TRUE


GENESIS Example with Parameter File 2:

		$ par2db.pl my_conductances.par
		$ qsub -t 1:100 ~/scripts/sim_genesis_1par.sh my_gen_script.g my_conductances.par

GENESIS Example w/o Parameter File:

		$ qsub ~/scripts/sim_genesis.sh my_gen_script.g

MATLAB Example 1:

		$ qsub -t 1:60 ~/scripts/sim_matlab.sh calculate(%d)

This will call the matlab functions `calculate(1), calculate(2),` ... etc. in each job.

MATLAB Example 2:

		$ qsub -t 1:60 ~/scripts/sim_matlab.sh load_part%d

This will call `load_part1, load_part2, ..., load_part60` in each matlab process.

Any executable with Parameter File:

		$ par2db my_conductances.par
		$ qsub -t 1:100 ~/scripts/sim_exec_1par.sh myexec my_conductances.par


3. Commonly used SGE commands
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

4. Cluster queue priorities
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

Modification history:
----------------------

- *Reorganization by Cengiz Gunay (cengique AT users.sf.net), 2015/05/27*
- *Documentation and modifications by Anca Doloc-Mihu (adolocm AT emory.edu), 2008/08/14*
- *Original scripts by Cengiz Gunay (cengique AT users.sf.net), 2005/06/05*
