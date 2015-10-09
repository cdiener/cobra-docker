Run the Cobrapy stack in docker
-------------------------------

This repo helps you to build a docker container running cobrapy on Python 3
and a jupyter notebook server apart from those two it also provides
the following "add-ons":

* optional https and passwords protection
* matplotlib and seaborn for plotting
* installation of commercial solvers (currently only cplex)
* additional command line lp solvers (clp, cbc and glpk)
* copy additional sbml models from the host

## Installation

If you do not want to install additional models and solvers, the image can be build with

```{bash}
mkdir solvers models
docker build -t cobra .
```

### Additional models

The models folder in the working directory will be copied automatically into
the working directory of the jupyter server. To add the Recon 2 model for instance
the following has to be done before running docker build:

```{bash}
wget https://www.ebi.ac.uk/biomodels-main/download?mid=MODEL1109130000 -O models/recon2.xml
```

### Commercial solvers

### Cplex

In order to have cplex installed you will need the current cplex install (12.6+)
and extract ists contents to the "solvers" directory into a subfolder "ibm".
You can do that by running the Cplex Installer and when prompted for the installation
directory choosing "solvers/ibm" in the directory from where you will build your docker
container. The Dockerfile will take care of the rest.  

## Planned changes

[ ] unprivileged user
[ ] more solvers
[ ] pdf export?

