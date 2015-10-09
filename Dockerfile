############################################################
# Dockerfile to build a jupyter app running cobrapy
# with most of the optional dependencies installed
############################################################

FROM debian
MAINTAINER Christian Diener "<mail@cdiener.com"

## Apt config
RUN apt-get update -y

## Debian package installs
RUN apt-get install -yq --no-install-recommends build-essential git \
    libbz2-dev libgmp-dev libzmq-dev openssl python3-dev python3-matplotlib \
    python3-numpy python3-scipy python3-tk python3-pil python3-pip \
    python3-lxml fonts-liberation coinor-cbc coinor-clp glpk-utils libglpk-dev \
    coinor-libcbc-dev coinor-libclp-dev libatlas-dev libatlas-base-dev libxml2-dev

## Solvers commercial
# Cplex
# The installer is interactive and can not run in docker build so we have to
# extract everything beforehand. For this run the cplex installer in the directory
# where you run docker build and choose the folder solvers/ibm in the current
# directory as install destination
COPY ./solvers ./solvers
RUN if [ -d ./solvers/ibm ]; then pip3 install ./solvers/ibm/cplex/python/3.4/x86-64_linux; fi
RUN cd /usr/bin && ln -s .solvers/opt/ibm/cplex/bin/x86-64_linux/cplex

## Install Cobra and Pip packages
RUN pip3 install jupyter python-libsbml pycddlib statsmodels pandas seaborn
RUN git clone https://github.com/opencobra/cobrapy /tmp/cobra_git
RUN pip3 install /tmp/cobra_git
RUN rm -rf /tmp/cobra_git

## Add models
WORKDIR root
COPY ./models ./models

## Clean up
RUN apt-get -y autoclean

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
