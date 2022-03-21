#!/bin/bash

for i in "$@"; do
  case $i in
    -f=*|--fast5_dir=*)
      FAST5_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # past argument=value
      ;;
    -l=*|--library=*)
      LIBRARY="${i#*=}"
      shift # past argument=value
      ;;
    -c=*|--config=*)
      CONFIG="${i#*=}"
      shift # past argument=value
      ;;
  esac
done

#FAST5_DIR=$1
#LIBRARY=$2
#SAMPLE=$3
#CONFIG=$4

source $CONFIG
RESULTS_DIR=$RESULTS_DIR
REFERENCE_FILE=$REFERENCE_FILE
CODE_LIB=$CODE_LIB
HM450_SITES=$HM450_SITES
CPGS_10K=$CPGS_10K
CONDA_DIR=$CONDA_DIR

source ${CONDA_DIR}/etc/profile.d/conda.sh
conda activate /b06x-isilon/b06x-m/mnp_nanopore/software/virtualenvs/rapid_cns_conda_env

echo $RESULTS_DIR
echo $FAST5_DIR
echo $REFERENCE_FILE
echo $CODE_LIB
echo $HM450_SITES
echo $CPGS_10K
echo $CONDA_DIR

