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
