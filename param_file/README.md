<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Parameter file scripts common to all platforms](#parameter-file-scripts-common-to-all-platforms)
    - [Using parameter files](#using-parameter-files)
    - [Running helpers](#running-helpers)
    - [Creating a grid-search parameter file from parameter definitions](#creating-a-grid-search-parameter-file-from-parameter-definitions)
    - [Passing and reading parameter rows into the GENESIS neural simulator](#passing-and-reading-parameter-rows-into-the-genesis-neural-simulator)
        - [Making GENESIS batch scripts for the NeuroScience Gateway (NSG)](#making-genesis-batch-scripts-for-the-neuroscience-gateway-nsg)
    - [See also](#see-also)

<!-- markdown-toc end -->

# Parameter file scripts common to all platforms

Parameter files are simple, so they can be generated in various
ways. If you want to generate parameter files of all combinations of
parameter values, we provide some
scripts
[below](#creating-a-grid-search-parameter-file-from-parameter-definitions).

## Using parameter files

Using the same example parameter file `5rows9pars.par`:

```
5 9 <-- Rows and columns
1 1 2.1 9 2 0.6 50 48 0
1 1 2.15 9 2 0.6 50 48 0
1 1 2.2 9 2 0.6 50 48 0
1 1 2.25 9 2 0.6 50 48 0
1 1 2.3 9 2 0.6 50 48 0
```

First, it should be compiled into a binary hashtable that allows
indexing:

```bash
$ ./par2db.pl 5rows9pars.par 
```

which would create the output `5rows9pars.par.db` file, which is a
Perl database (db). This db provides fast access to arbitrary
parameter rows using a hash key into the hashtable, as opposed to
reading the corresponding line from the parameter file by parsing it,
which is much slower.

*Note*: The db file could be large. Make sure there is enough space on
the disk.

Rows from the database can be accessed with the syntax (note the `.db`
extension is omitted):

```bash
$ ./get_1par.pl 5rows9pars.par 3
```

will give 

```
1 1 2.2 9 2 0.6 50 48 0
```

Scripts:

- `par2db.pl` Creates binary database from parameter file.
- `get_1par.pl` Gets one parameter line from file using index.
- `splitparfile` Splits parameter file into several pieces for parallel execution.

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

## Creating a grid-search parameter file from parameter definitions

Parameter definition files allow automatically generating parameter
sets of all combinations (grid-search) of given parameter values. They
also keep parameter names and their order for other scripts (see
the
[Genesis section](#passing-and-reading-parameter-rows-into-the-genesis-neural-simulator) below). To
generate a parameter file `output_param_file.par` from a definition
file `input_def_file.txt`, use command:


```bash
$ ./def2par.pl output_param_file < input_def_file.txt
```

A definition `.txt` file specifies values of each parameter on a separate
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
 
## Passing and reading parameter rows into the GENESIS neural simulator

Because the GENESIS neural simulator cannot parse command line
parameters, environment variables are used to pass parameter names and
values:

```bash
$ export GENESIS_PAR_ROW=`path/get_1par.pl param_file line_no`   //general syntax
```

This is done automatically with the `get_genesis_pars.sh` script:

```bash
$ get_genesis_pars.sh 5rows9pars.par 3
GENESIS_PAR_ROW="1 1 2.2 9 2 0.6 50 48 0" GENESIS_PAR_NAMES="..."
```

If GENESIS is called after this line, it can extract parameter values
from these environment variables using the functions by including the
file `readParameters.g`. In this example the parameter names are not
found, but they would be extracted if a parameter definition file with
a matching `.txt` extension exists. This file is parsed only for the
parameter names at the beginning of the lines, so it is not limited to
grid-search files. Passed parameter environment variables are then
parsed by first calling the function `read_env_params` and then
accessing the parameters either by name:

```
par_a = {get_param_byname "a"}
```

or by index:

```
par_b = {get_param 2}
```

See inside `readParameters.g` for more information about its
usage. GENESIS can be called with the command:

```bash
$ time genesis -nox -batch -notty my_genesis_script.g 2>&1 
```
or by using the `sim_genesis_1par.sh` script:

```bash
PSN_TRIAL=3 GENESIS=lgenesis sim_genesis_1par.sh my_genesis_script.g 5rows9pars.par
```

which would execute the `lgenesis` flavor of GENESIS with the 3rd
parameter row by following the above steps automatically.

### Making GENESIS batch scripts for the NeuroScience Gateway (NSG)

For high performance resources that do not allow calling these
sequence of scripts, one can create a long batch file that contains
all environment variable settings and calls to the simulator:

```bash
$ par2batch_genesis.sh my_genesis_script.g 5rows9pars.par > batch.sh
```

where the batch file will contain lines like this:

```bash
GENESIS_PAR_ROW="1 1 0.55 2.4 2 0.6 500 480 0" GENESIS_PAR_NAMES="" lgenesis -nox -batch -notty my_genesis_script.g
GENESIS_PAR_ROW="1 1 0.575 2.4 2 0.6 500 480 0" GENESIS_PAR_NAMES="" lgenesis -nox -batch -notty my_genesis_script.g
...
```

NeuroScience Gateway scheduling scripts can then take this file and
split it into smaller pieces for distribution.

Scripts:
 - `readParameters.g` GENESIS functions for extracting parameters from environment variables.
 - `get_genesis_pars.sh` Get one parameter line and fill GENESIS
   environment variables. Used in `sim_genesis_1par.sh`.
 - `sim_genesis_1par.sh` Cluster-agnostic script that runs Genesis with 1 parameter line.
 - `par2batch_genesis.sh` Creates a GENESIS execution batch file from a parameter set.

## See also
To create parameter files from within Matlab, also see the [Pandora
toolbox](https://github.com/cengique/pandora-matlab). Use the
`scaleParamsOneRow`, `scanParamsAllRows`, `makeGenesisParFile` functions in
the `params_tests_db` object.

Documentation credits: Cengiz Gunay and Anca Doloc-Mihu.
