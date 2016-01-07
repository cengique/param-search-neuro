## Scripts specific to the [SLURM](https://computing.llnl.gov/linux/slurm/) scheduler

 - `slurm_example_template.sh` Copy this script locally and customize.
 - `slurm_sim_genesis_1par.sh` Extracts parameters from SLURM and calls `../param_file/sim_genesis_1par.sh`
 - `slurm_matlab.sh` Script for submitting a Matlab job.

### Workflow:
  Start by copying and renaming `slurm_example_template.sh` into your local project. Customize the SLURM directives inside and change its last line to execute one of the available SLURM scripts above. There are usage instructions both as comments and runtime help displayed by the scripts. For instance to submit an array job, use:
 
    sbatch -a start-end slurm_example_template.sh
