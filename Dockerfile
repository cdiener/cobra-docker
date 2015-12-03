############################################################
# Dockerfile to build a jupyter app running cobrapy
# with most of the optional dependencies installed
#
############################################################

FROM debian
MAINTAINER Christian Diener "<mail@cdiener.com>"

## Apt config
RUN apt-get update -y

## Debian package installs
RUN apt-get install -yq --no-install-recommends build-essential git fontconfig\
    libbz2-dev libgmp-dev libzmq-dev openssl python3-dev python3-matplotlib\
    python3-numpy python3-scipy python3-tk python3-pil python3-pip cython3 \
    python3-lxml fonts-liberation coinor-cbc coinor-clp glpk-utils libglpk-dev \
    coinor-libcbc-dev coinor-libclp-dev libatlas-dev libatlas-base-dev libxml2-dev
RUN fc-cache -fv

## Solvers commercial
# Cplex
# The installer is interactive and can not run in docker build so we have to
# extract everything beforehand. For this run the cplex installer in the directory
# where you run docker build and choose the folder solvers/ibm in the current
# directory as install destination
COPY ./solvers /solvers
RUN if [ -d /solvers/ibm ]; then pip3 install /solvers/ibm/cplex/python/3.4/x86-64_linux \
    cp ./solvers/ibm/cplex/bin/x86-64_linux/cplex /usr/bin/; fi

# Gurobi currently in active due to problems with obtaining the license
# inside docker
# Gurobi unpack the the tar.gz in a folder named gurobi inside of solvers
# put your license into the same folder (e.g. ./solvers/gurobi/gurobi.lic)
# RUN mkdir /opt/gurobi
# RUN if [ -d ./solvers/gurobi ]; then cp ./solvers/gurobi/gurobi.lic /opt/gurobi/; fi
# RUN if [ -d ./solvers/gurobi ]; then pip3 install ./solvers/gurobi/linux64; fi
RUN rm -rf /solvers

## Install Cobra and Pip packages
RUN pip3 install jupyter python-libsbml palettable pycddlib statsmodels pandas seaborn
RUN git clone https://github.com/opencobra/cobrapy /tmp/cobra_git
RUN pip3 install /tmp/cobra_git

## Add models
WORKDIR root
COPY ./models /models

## Clean up
RUN apt-get -yq purge build-essential && apt-get -yq autoremove && apt-get -yq clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Configure Notebook server
# We use the config from jupyter/minimal-notebook but do not want to use conda
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/minimal-notebook/jupyter_notebook_config.py .jupyter/
ENV JUPYTER_CONFIG_DIR=/root/.jupyter

## Run the notebook server
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD ["jupyter", "notebook"]
