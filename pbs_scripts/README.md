## Scripts specific to the PBS/[Moab](http://www.adaptivecomputing.com/) scheduler

 - `pbs_example_template.sh` Copy this script locally and customize.
 - `pbs_sim_genesis_1par.sh` Extracts parameters from PBS/Moab and calls `../param_file/sim_genesis_1par.sh`
 - `pbs_matlab.sh` Script for submitting a Matlab job.

### Workflow:
  Start by copying and renaming `pbs_example_template.sh` into your local project. Customize the PBS directives inside and change its last line to execute one of the available PBS scripts above. There are usage instructions both as comments and runtime help displayed by the scripts.
