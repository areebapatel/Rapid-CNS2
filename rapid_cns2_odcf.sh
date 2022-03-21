#--------------------------------------------------------------------
#
#
# Developed and maintained by
# Areeba Patel
# a.patel@dkfz.de                                                                  
# 
# 31-08-2021 
#--------------------------------------------------------------------  

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
echo "${CONFIG}"
RESULTS_DIR=$RESULTS_DIR
REFERENCE_FILE=$REFERENCE_FILE
CODE_LIB=$CODE_LIB
HM450_SITES=$HM450_SITES
CPGS_10K=$CPGS_10K
CONDA_DIR=$CONDA_DIR
GPU_DIR=$GPU_DIR

source ${CONDA_DIR}/etc/profile.d/conda.sh
conda activate /b06x-isilon/b06x-m/mnp_nanopore/software/virtualenvs/rapid_cns_conda_env

LIB_PATH=${RESULTS_DIR}/${LIBRARY}/
LOG_DIR=${LIB_PATH}/logs/
mkdir -p $LIB_PATH
mkdir -p $LOG_DIR
mkdir -p ${LIB_PATH}/fastq/
mkdir -p ${LIB_PATH}/bam/
mkdir -p ${LIB_PATH}/QC/
mkdir -p ${LIB_PATH}/cnv/
mkdir -p ${LIB_PATH}/deepvariant/
mkdir -p ${LIB_PATH}/longshot/
mkdir -p ${LIB_PATH}/annovar/
mkdir -p ${LIB_PATH}/svim/
mkdir -p ${LIB_PATH}/special_positions/
mkdir -p ${LIB_PATH}/methylation_classification/

#Guppy basecalling
GUPPY_DIR=${LIB_PATH}/guppy/
GUPPY_JOB=${LIBRARY}_guppy
bsub -gpu num=1:j_exclusive=yes:mode=exclusive_process:gmem=20G -q gpu -J ${GUPPY_JOB} bash ${CODE_LIB}/lsf/guppy_dkfz.sh $FAST5_DIR $GUPPY_DIR $LIBRARY $GPU_DIR $CONFIG

#megalodon modified basecalling
MEGALODON_DIR=${LIB_PATH}/megalodon/
MEGALODON_JOB=${LIBRARY}_megalodon
bsub -gpu num=1:j_exclusive=yes:mode=exclusive_process:gmem=20G -q gpu -J ${MEGALODON_JOB} bash ${CODE_LIB}/lsf/megalodon_dkfz.sh $FAST5_DIR $MEGALODON_DIR $LIBRARY $GPU_DIR $CONFIG

#MGMT
MGMT_JOB=${LIBRARY}_MGMT
bsub -R rusage[mem=64G] -w "done($MEGALODON_JOB)" -q verylong -J ${MGMT_JOB} bash ${CODE_LIB}/lsf/mgmt_sites.sh $LIBRARY $SAMPLE

#Methylation classification
MC_JOB=${LIBRARY}_methylation_classification
bsub -n 4 -R rusage[mem=64G] -w "done($MGMT_JOB)" -q verylong -J ${MC_JOB} -e ${LOG_DIR}/methylation_classification.err -o ${LOG_DIR}/methylation_classification.log "Rscript ${CODE_LIB}/lsf/methylation_classification.R -l $LIB_PATH -s $SAMPLE -c $CPGS_10K -a $HM450_SITES" 


#Get QC report using pycoQC
bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($GUPPY_JOB)" -e ${LOG_DIR}/pycoQC.err -o ${LOG_DIR}/pycoQC.log -J ${LIBRARY}_pycoqc bash ${CODE_LIB}/lsf/pycoqc.sh $LIBRARY $SAMPLE

#Trim adapters
TRIM_JOB=${LIBRARY}_trim
bsub -n 64 -R "rusage[mem=20G]" -q long -w "done($GUPPY_JOB)" -e ${LOG_DIR}/trim.err -o ${LOG_DIR}/trim.log -J ${TRIM_JOB} bash ${CODE_LIB}/lsf/trimming.sh $LIBRARY $SAMPLE 64


#Align fastq file
ALIGN_JOB=${LIBRARY}_align
bsub -n 64 -R "rusage[mem=20G]" -q long -w "done($TRIM_JOB)" -e ${LOG_DIR}/align.err -o ${LOG_DIR}/align.log -J ${ALIGN_JOB} bash ${CODE_LIB}/lsf/alignment_dna.sh $LIBRARY $SAMPLE 64

#Call CNVs
CNV_JOB=${LIBRARY}_cnv
bsub -n 64 -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -e ${LOG_DIR}/cnv.err -o ${LOG_DIR}/cnv.log -J ${CNV_JOB} bash ${CODE_LIB}/lsf/cnvpytor.sh $LIBRARY $SAMPLE 64

#Deepvariant
DEEPVARIANT_JOB=${LIBRARY}_deepvariant
bash ${CODE_LIB}/lsf/deepvariant.sh ${LIBRARY} $SAMPLE 64 $ALIGN_JOB

bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($DEEPVARIANT_JOB)" -J ${LIBRARY}_deepvariant_annovar -e ${LOG_DIR}/deepvariant_annovar.err -o ${LOG_DIR}/deepvariant_annovar.log bash ${CODE_LIB}/lsf/deepvariant_annovar.sh $LIBRARY $SAMPLE

#Variant and SV calling
bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_svim -e ${LOG_DIR}/svim.err -o ${LOG_DIR}/svim.log bash ${CODE_LIB}/lsf/svim.sh $LIBRARY $SAMPLE

bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_longshot -e ${LOG_DIR}/longshot.err  -o ${LOG_DIR}/longshot.log bash ${CODE_LIB}/lsf/longshot.sh $LIBRARY $SAMPLE

bsub -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_special_pos -e ${LOG_DIR}/special_pos.err -o ${LOG_DIR}/special_pos.log bash ${CODE_LIB}/lsf/special_positions.sh $LIBRARY $SAMPLE

#Nanopolish
#NANOPOLISH_IMG=$NANOPOLISH_IMG
#bsub -n 32 -R "rusage[mem=24G]" -q verylong -w "done($ALIGN_JOB)"  -J ${LIBRARY}_nanopolish -e ${LOG_FOLDER}/nanopolish.err -o ${LOG_FOLDER}/nanopolish.log singularity exec --bind /b06x-isilon/b06x-m/mnp_nanopore/:/mnp_nanopore  $NANOPOLISH_IMG bash ${CODE_LIB}/nanopolish.sh ${LIBRARY} ${SAMPLE} 32

