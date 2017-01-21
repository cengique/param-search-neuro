Parallel parameter search scripts for simulating neuron models
======================================================================

`param-search-neuro` is a collection of scripts to simulate a neuron
model for each of the entries in a parameter set, but in practice it
could run any simulator. Evaluating the model at different places in
its parameter space allows mapping its output and also
creating
[neuronal model databases](http://link.springer.com/referenceworkentry/10.1007/978-1-4614-7320-6_165-1).

It provides a simple method to run a set of parameters locally or on
high-performance computing (HPC) platforms by defining the concept of a
parameter file. This is a text file that contains a matrix of numbers,
where columns represent different parameters and rows represent
different model runs or trials:

```
5 9 <-- Rows and columns
1 1 2.1 9 2 0.6 50 48 0
1 1 2.15 9 2 0.6 50 48 0
...
```

The trials can then be simulated serially or in parallel through the
use of the provided scripts. Scripts here allow constructing the
parameter file in a variety of ways, including but not limited to
selecting all combinations of discrete values of each
parameter. Parameter files can also be easily imported from other
sources.

Using these scripts is __efficient__ because, before running
simulation sets, text parameter files are compiled into __binary
objects__ (using Perl). These hashtable objects reach parameters of
requested trials in constant time (i.e. _O(1)_) and allows direct
addressing of trials. Therefore they can be executed in arbitrary
order, which is necessary in parallel environments because it
eliminates the need __to prevent race conditions__.

HPC platforms supported:

* Sun Grid Engine (SGE)
* PBS/MOAB
* SLURM

Running parameter sets on parallel environments is demonstrated using
the GENESIS simulator here, but in principle it is very easy to run
any other simulator. Parameters are passed to individual GENESIS
processes using environmental variables, but they can also be passed
on the command line.

To use these scripts, either add the paths `param_file/` and your
cluster-specific script directory (e.g., `pbs_scripts`) in your search
PATH, or refer to these scripts with full paths.

See the tutorial below and the examples in the relevant subdirectories
for up-to-date usage.

Directory organization
----------------------------------------

* [`param_file/`](param_file/): Common scripts for running simulations
  and for maintaining parameter files.
* [`pbs_scripts/`](pbs_scripts/): Scripts specific to
  PBS/[Moab](http://www.adaptivecomputing.com/).
* [`slurm_scripts/`](slurm_scripts/): Scripts specific
  to [SLURM](https://computing.llnl.gov/linux/slurm/).
* [`sge_scripts/`](sge_scripts/): Scripts specific to
  the
  [Sun/Oracle Grid Engine (SGE)](https://en.wikipedia.org/wiki/Oracle_Grid_Engine).
* [`maintenance/`](maintenance/): Miscellaneous cluster and file
  maintenance scripts.

Subdirectories contain additional documentation. Start with
the [parameter file documentation](param_file/).

### Tutorial:

1. Introduction
2. Parameter search tutorial
3. Other command usage examples

1. Introduction
---------

This tutorial demonstrates how to run a set of simulations on a
high-performance cluster based on a parameter set. Commands and
examples are given for running neuron simulations
in [GENESIS](http://www.genesis-sim.org) and for cluster schedulers
SGE and PBS/MOAB. However, the workflow and common scripts provide a
general method, and could be adapted to other platforms.

Before running simulations on a cluster, you must first make some
preparation. This tutorial explains how to do these preparations step
by step. The files needed for them are included in this directory and
explained at each step.

To learn about the Sun Grid Engine (SGE) on how to submit 
and monitor jobs, start from the "man sge_intro" manual page. 

Use the "qsub" command to submit jobs to the SGE or PBS/MOAB.


2. Parameter search tutorial
-----------------

This setting is for simulations run on clusters, for which we give the
parameters of the model outside the model in an ASCII input file, in a
very convenient format (4 formats accepted at this time). This input
file is transformed into another file containing all the possible
parameter combinations, with each combination on one line. Further,
each line will furnish input parameters for each simulation.


### Steps for running simulations on local machine.

	
	*Note*: The Perl script file def2par.pl reads the
    `input_ASCII_file.txt` and creates the parameter combinations file
    `all_sim_comb.par`. The first line of this file contains the
    number of combinations (or, number of lines in the file,
    equivalent to the number of simulations) and the (number of
    parameters + 1). The rest of the lines are all the same: "list of
    parameters no_of_line 0". E.g. (first 5 lines of the
    `all_sim_comb.par` file):

		390625 9
		-0.065 0 0 0 0 0 0 0 1 0
		-0.055 0 0 0 0 0 0 0 2 0
		-0.050 0 0 0 0 0 0 0 3 0
		-0.040 0 0 0 0 0 0 0 4 0
		-0.030 0 0 0 0 0 0 0 5 0
	


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


2. Other command usage examples (with SGE, but can be adapted to other platforms)
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

Modification history:
----------------------

- *Reorganization by Cengiz Gunay (cengique AT users.sf.net), 2015-2016*
- *Documentation and modifications by Anca Doloc-Mihu (adolocm AT emory.edu), 2008/08/14*
- *Original scripts by Cengiz Gunay (cengique AT users.sf.net), 2005/06/05*
