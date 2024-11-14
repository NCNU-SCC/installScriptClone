# installScript

## Usage
### genTemplateScript.sh
This script will generate a script, which it will automatically load depenedent module, get source code, config, make, make install and write module file.

Exmaple:
```
genTemplateScript.sh gmp-6.2.1/gmp-6.2.1.sh 
```
It will create `gmp-6.2.1/gmp-6.2.1.sh`.
You can query the file `gmp-6.2.1/gmp-6.2.1.sh` for `Need to modify` to find out what needs to be modified.
For 
`URL="https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz"`:
It will get source code from `URL`.

`DEP`:
`INSTALLPATH`, 
`MF`,  
`configure options`.

, load all the dependence in `DEP` in format `"gcc-8.4.0"`, which will run `module load gcc/8.4.0`.
`INSTALLPATH` is the place where binary will installed.
`MF` is the place where module file will be written to.
`configure options` already has some optimization parameters

After modification, run `./gmp-6.2.1/gmp-6.2.1.sh`.

## Contribution




# installScriptClone
