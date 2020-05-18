#!/bin/bash
# script adapted from https://bytes.babbel.com/en/articles/2017-07-04-spark-with-jupyter-inside-vpc.html

# # mount home to /mnt
# if [ ! -d /mnt/home ]; then
#   	  sudo mv /home/ /mnt/
#   	  sudo ln -s /mnt/home /home
# fi
	
# Install conda
wget https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh -O $HOME/miniconda.sh 
/bin/bash ~/miniconda.sh -b -p $HOME/conda

echo 'export PATH=$HOME/conda/bin:$PATH' >> $HOME/.bashrc 
source $HOME/.bashrc
conda config --set always_yes yes --set changeps1 no
	
# Install additional libraries for all instances with conda
conda install conda=4.2.13

conda config -f --add channels conda-forge
conda config -f --add channels defaults

conda install hdfs3 findspark ujson jsonschema toolz boto3 py4j numpy pandas==0.19.2
	
# cleanup
rm ~/miniconda.sh
	
echo bootstrap_conda.sh completed. PATH now: $PATH
