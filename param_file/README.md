## Common scripts for running simulations and for maintaining parameter files.

### Parameter file related scripts

- `def2par.pl`	Generates a parameter file from a definition file.
- `def2parN.pl` Generates N parameter files from a definition file.
- `par2db.pl` Creates binary database from parameter file.
- `get_1par.pl` Gets one parameter line from file using index.
- `splitparfile` Splits parameter file into several pieces.

### Example parameter definition files

 - `paramDefMult.txt` Example parameter definition file with multiplicative rule.
 - `paramDef.txt` Example parameter definition file.
 
### GENESIS related scripts
 - `readParameters.g` GENESIS functions for extracting parameters from environment variables.
 - `sim_genesis_1par.sh` Cluster-agnostic script that runs Genesis with 1 parameter line.

### See also
To create parameter files from within Matlab, also see the [Pandora
toolbox](https://github.com/cengique/pandora-matlab). Use the
`scaleParamsOneRow`, `scanParamsAllRows`, `makeGenesisParFile` functions in
the `params_tests_db` object.
