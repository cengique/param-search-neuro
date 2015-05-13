### Shell and simulation scripts to manage parameter files.

 - `def2parN.pl` Generates N parameter files from a definition file.
 - `def2par.pl`	Generates a parameter file from a definition file.
 - `get_1par.pl` Gets one parameter line from file using index.
 - `par2db.pl` Creates binary database from parameter file.
 - `paramDefMult.txt` Example parameter definition file with multiplicative rule.
 - `paramDef.txt` Example parameter definition file.
 - `splitparfile` Splits parameter file into several pieces.
 - `readParameters.g` GENESIS functions for extracting parameters from environment variables.

To create parameter files from within Matlab, also see the [Pandora
toolbox](https://github.com/cengique/pandora-matlab). Use the
`scaleParamsOneRow`, `scanParamsAllRows`, `makeGenesisParFile` functions in
the `params_tests_db` object.