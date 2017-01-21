<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Parameter file scripts common to all platforms](#parameter-file-scripts-common-to-all-platforms)
    - [Using parameter files](#using-parameter-files)
    - [Running helpers](#running-helpers)
    - [Creating a grid-search parameter file from parameter definitions](#creating-a-grid-search-parameter-file-from-parameter-definitions)
    - [GENESIS related scripts](#genesis-related-scripts)
    - [See also](#see-also)

<!-- markdown-toc end -->

# Parameter file scripts common to all platforms

Parameter files are simple, so they can be generated in various
ways. If you want to generate parameter files of all combinations of
parameter values, we provide some scripts [below](#creating-a-grid-search-parameter-file-from-parameter-definitions).

<a id="using-parameter-files"/>
## Using parameter files

First, a parameter file `all_sim_comb.par` should be compiled into a
binary hashtable that allows indexing:

```bash
$ ./par2db.pl all_sim_comb.par 
```

which would create the output `all_sim_comb.par.db` file, which is a
Perl database (db). This db provides fast access to arbitrary
parameter rows using a hash key into the hashtable, as opposed to
reading the corresponding line from the parameter file by parsing it,
which is much slower.

*Note*: The db file could be large. Make sure there is enough space on
the disk.

Rows from the database can be accessed with the syntax:

```bash
$ ./get_1par.pl param_file line_no
```

For instance, accessing line 8 (the 8th parameter combination) of the
`all_sim_comb.par.db` is achieved by:

```bash
$ ./get_1par.pl all_sim_comb.par 8
```

Scripts:

- `par2db.pl` Creates binary database from parameter file.
- `get_1par.pl` Gets one parameter line from file using index.
- `splitparfile` Splits parameter file into several pieces for parallel execution.

<a id="running-helpers"/>
## Running helpers

Parameter files can be parsed and simulations executed on single
workstations or high-performance platforms (see HPC
subfolders). Complete or subsets of parameter sets can be run locally
with:

```bash
$ run_local.sh param_range sim_script [args...]
```

where if `param_range` is of the form N:M, then rows N through M will
be retireved and `sim_script` will be called with the rest of the
command line arguments. Otherwise, `param_range` is assumed to be the
name of the parameter file, and all parameter rows will be
executed. `sim_script` will be passed an environment variable
`PSN_TRIAL` which would inficate the row number of the parameter
set. This number can be used, inside the script, to get the parameter
values using the `get_1par.sh` mechanism above.

Parameter sets can also be executed in multiple threads on the same
machine using:

```bash
$ run_local_multi.sh num_threads param_range sim_script [args...]
```

which takes an additional `num_threads` argument compared to
`run_local.sh` that indicates how many threads to execute. Then, the
parameter range will be divided into equal subsets and executed in
parallel.

Scripts:

 - `run_local.sh` Runs parameter set with the desired executable on the local machine.
 - `run_local_multi.sh` Runs a parameter set on multiple threads on local machine.

<a id="creating-a-grid-search-parameter-file-from-parameter-definitions"/>
## Creating a grid-search parameter file from parameter definitions

Parameter definition files allow automatically
generating parameter sets of all combinations (grid-search) of given
parameter values. To generate a parameter file `output_param_file.par`
from a definition file `input_def_file.txt`, use command:

```bash
$ ./def2par.pl output_param_file < input_def_file.txt
```

A definition file specifies values of each parameter on a separate
row, which can have one of the following four formats:

 1. Additive increments

			param_name range_low range_high num_steps

 2. Multiplicative increments

			param_name base_val *mul_factor ^num_steps

 3. Choose from a list

			param_name [ val1 val2 ... ]

 4. Independent counter (indicates trial number)

			param_name start_val ++ [increment]
			
	and, the last line is standard: `trial 1 ++`

For instance, the leech model parameter definitions in
`paramLista.txt` uses option 3, lists:

		eLeak [ -0.065 -0.055 -0.050 -0.040 -0.030 ]
		gBar1 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar2 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar3 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar4 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar5 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar6 [ 0 -0.3 -0.6 0.2 0.4 ]
		gBar7 [ 0 -0.3 -0.6 0.2 0.4 ]
		trial 1 ++

Also see the two examples `paramDef.txt` and `paramDefMult.txt`.

Scripts:

- `def2par.pl` Generates a parameter file from a definition file. Run
  without arguments to get more help.
- `def2parN.pl` Generates N parameter files from a definition file to
  be run in parallel.

Example definition files:

- `paramDefMult.txt` Example parameter definition file with multiplicative rule.
- `paramDef.txt` Example parameter definition file.


 
## GENESIS related scripts
 - `readParameters.g` GENESIS functions for extracting parameters from environment variables.
 - `get_genesis_pars.sh` Get one parameter line and fill GENESIS
   environment variables. Used in `sim_genesis_1par.sh`.
 - `sim_genesis_1par.sh` Cluster-agnostic script that runs Genesis with 1 parameter line.
 - `par2batch_genesis.sh` Creates a GENESIS execution batch file from a parameter set.

<a id="see-also"/>
## See also
To create parameter files from within Matlab, also see the [Pandora
toolbox](https://github.com/cengique/pandora-matlab). Use the
`scaleParamsOneRow`, `scanParamsAllRows`, `makeGenesisParFile` functions in
the `params_tests_db` object.
