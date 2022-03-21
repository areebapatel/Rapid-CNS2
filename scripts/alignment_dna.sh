#!/usr/bin/env bash

for i in "$@"; do
  case $i in
    -f=*|--fastq=*)
      FASTQ="${i#*=}"
      shift # trimmed fastq file
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # output dir for bam files
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample
      ;;
    -r=*|--reference=*)
      REFERENCE="${i#*=}"
      shift # hg19 reference file
      ;;
      -t=*|--threads=*)
      THREADS="${i#*=}"
      shift
  esac
done

#Align FASTQ
BAM_FILE=${OUT_DIR}/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam
mkdir -p ${OUT_DIR}

cd ${OUT_DIR}
minimap2 -ax map-ont --MD ${REFERENCE} ${FASTQ} | samtools view -bS -@ ${THREADS} | samtools sort > ${BAM_FILE}

samtools index ${BAM_FILE}
