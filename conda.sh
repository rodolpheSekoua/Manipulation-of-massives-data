#!/bin/bash
   
#install conda
wget https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh -O /home/hadoop/miniconda.sh\
	&& /bin/bash ~/miniconda.sh -b -p $HOME/conda

echo '\nexport PATH=$HOME/conda/bin:$PATH' >> $HOME/.bashrc && source $HOME/.bashrc

conda config --set always_yes yes --set changeps1 no
conda install conda=4.2.13
conda config -f --add channels conda-forge
conda config -f --add channels defaults

conda install hdsf3 findspark ujson jsonschema toolz boto3 py4j numpy pandas==0.19.2
#cleanup 
rm ~/miniconda.sh

echo bootstrap_conda.sh completed. PATH now: $PATH
