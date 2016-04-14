############################################################
# Dockerfile to build a jupyter app running cobrapy
# with most of the optional dependencies installed
#
############################################################

FROM jupyter/minimal-notebook
MAINTAINER Christian Diener "<mail@cdiener.com>"

USER jovyan

RUN conda install --quiet --yes -c bioconda\
    python=3.4 \
    numpy \
    matplotlib \
    pandas \
    statsmodels \
    seaborn \
    cobra \
    && pip install https://github.com/cdiener/corda/archive/master.zip \
    && conda clean -tipsy

USER root

## Solvers commercial
# Cplex
# The installer is interactive and can not run in docker build so we have to
# extract everything beforehand. For this run the cplex installer in the directory
# where you run docker build and choose the folder solvers/ibm in the current
# directory as install destination
COPY ./solvers /solvers
RUN if [ -d /solvers/ibm ]; then cd /solvers/ibm/cplex/python/3.4/x86-64_linux/ && \
    python3 setup.py install &&\
    cp /solvers/ibm/cplex/bin/x86-64_linux/cplex /usr/bin/; fi && rm -rf /solvers
