#!/usr/bin/bash

for i in "$@"; do
  case $i in
    -f=*|--fastq_dir=*)
      FASTQ_DIR="${i#*=}"
      shift # fastq_pass dir (multiple fastq files)
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # output dir for fastq files
      ;;
    -p=*|--porechop_path=*)
      PORECHOP_PATH="${i#*=}"
      shift # path to Porechop dir containing porechop-runner.py script
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample name, fastq files will be named using this
      ;;
    -t=*|--threads=*)
      THREADS="${i#*=}"
      shift # number of threads
      ;;
  esac
done


#Trim adapters
FASTQ_IN=${OUT_DIR}/${SAMPLE}_pass.fastq.gz
FASTQ_OUT=${OUT_DIR}/${SAMPLE}_adapter_trimmed.fastq.gz


cat ${FASTQ_DIR}/* > ${FASTQ_IN}

cd ${PORECHOP_PATH}/
python3 porechop-runner.py -i $FASTQ_IN -o $FASTQ_OUT -t $THREADS --verbosity 3
