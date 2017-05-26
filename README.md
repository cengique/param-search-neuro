Parallel parameter search scripts for simulating neuron models
======================================================================

**Update on 5/26/2017:** Parameter search using this tool is now implemented on the [Neuroscience Gateway (NSG)](https://www.nsgportal.org/) neural simulation platform. To use it, select "Parameter Search in Singularity on Comet" from the tools list. So far it's only limited to calling GENESIS 2.4, but potentially it could call any simulator or any other program.

`param-search-neuro` is a collection of scripts to simulate a neuron
model for each of the entries in a parameter set, but in practice it
could run any simulator. Evaluating the model at different places in
its parameter space allows mapping its output and also
creating
[neuronal model databases](http://link.springer.com/referenceworkentry/10.1007/978-1-4614-7320-6_165-1).

It provides a simple method to run a set of parameters locally or on
high-performance computing (HPC) platforms by defining the concept of
a parameter file. This is a text file that contains a matrix of
numbers, where columns represent different parameters and rows
represent different model runs or trials with different parameter
configurations. 

Here's an example parameter file `5rows9pars.par` with 5 rows of
different parameter configurations and 9 columns of parameters:

```bash
5 9 # Rows and columns
1 1 2.1 9 2 0.6 50 48 0
1 1 2.15 9 2 0.6 50 48 0
1 1 2.2 9 2 0.6 50 48 0
1 1 2.25 9 2 0.6 50 48 0
1 1 2.3 9 2 0.6 50 48 0
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

* Sun/Oracle Grid Engine (SGE)
* PBS/MOAB
* SLURM

Running parameter sets on parallel environments is demonstrated using
the [GENESIS](http://www.genesis-sim.org) simulator here, but in
principle it is very easy to run any other simulator. Parameters are
passed to individual GENESIS processes using environmental variables,
but they can also be passed on the command line.

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

Full examples for several simulation programs are provided under the
[SGE subfolder](sge_scripts/).

**Documentation credits**: Cengiz Gunay (cengique AT users.sf.net) and
Anca Doloc-Mihu (adolocm AT emory.edu).
