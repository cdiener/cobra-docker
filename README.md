Run the Cobrapy stack in docker
-------------------------------

This repo helps you to build a docker container running cobrapy on Python 3
and a jupyter notebook server apart from those two it also provides
the following "add-ons":

* optional https and passwords protection
* reconstruction of metabolic models using [CORDA](https://github.com/cdiener/corda)
* unpriviliged user
* Latex to export notebooks as PDF
* matplotlib and seaborn for plotting
* installation of commercial solvers (only cplex, please contact me or send a pull
  request if you want to help out with gurobi and mosek)
* copy additional sbml models from the host

## Installation

The image is built automatically by the docker automated build system. To get
the latest version just pull it in docker. Obviously, this will *NOT* include
commercial solvers.

```bash
docker pull cdiener/cobra
```

### Building locally

A local version including commercial solvers and customized models can be
built with

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

### Environment variables

This container supports some of the environment variables of the [minimal Jupyter image](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook). The most important ones are:

- PASSWORD - to set a password for the notebook
- USE_HTTPS - to use https (will require you to access the notebook via https://localhost:PORT

So you can run a notebook server with HTTPS and password "notebook" at https://localhost:8888
with

```bash
docker run -p 8888:8888 -e PASSWORD="notebook" USE_HTTPS=yes cobra
```

## Planned changes

- [X] unprivileged user
- [ ] more solvers
- [X] pdf export?
