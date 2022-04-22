#--------------------------------------------------------------------
#
#
# Developed and maintained by
# Areeba Patel
# a.patel@dkfz.de                                                                  
# 
# 07-04-2022 
#--------------------------------------------------------------------  

#!/bin/bash

for i in "$@"; do
  case $i in
    -q=*|--fastq_dir=*)
      FASTQ_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # past argument=value
      ;;
    -o=*|--out_dir=*)
      LIB_PATH="${i#*=}"
      shift # past argument=value
      ;;
    -c=*|--config=*)
      CONFIG="${i#*=}"
      shift # past argument=value
      ;;
  esac
done

source $CONFIG
REFERENCE_HG19=$REFERENCE_HG19
MMI_HG38=$MMI_HG38
MMI_HG19=$MMI_HG19
PROBES=$PROBES
TRAINING_DATA=$TRAINING_DATA
ARRAY_FILE=$ARRAY_FILE
CONDA_DIR=$CONDA_DIR
GUPPY_PATH=$GUPPY_PATH
PORECHOP_PATH=$PORECHOP_PATH
DEEPVARIANT_PATH=$DEEPVARIANT_PATH
ANNOVAR_PATH=$ANNOVAR_PATH
ANNOVAR_DB=$ANNOVAR_DB
PANEL=$PANEL
MGMT_BED=$MGMT_BED
MGMT_PROBES=$MGMT_PROBES
MGMT_MODEL=$MGMT_MODEL
TARGETS=$TARGETS

source ${CONDA_DIR}/etc/profile.d/conda.sh
conda activate rapid_cns_conda_env

LOG_DIR=${LIB_PATH}/logs
mkdir -p $LIB_PATH
mkdir -p $LOG_DIR
mkdir -p ${LIB_PATH}/fastq/
mkdir -p ${LIB_PATH}/bam/
mkdir -p ${LIB_PATH}/cnv/
mkdir -p ${LIB_PATH}/deepvariant/
mkdir -p ${LIB_PATH}/longshot/
mkdir -p ${LIB_PATH}/annovar/
mkdir -p ${LIB_PATH}/svim/
mkdir -p ${LIB_PATH}/special_positions/
mkdir -p ${LIB_PATH}/methylation_classification/
mkdir -p ${LIB_PATH}/coverage/
mkdir -p ${LIB_PATH}/report/


#Get QC report using pycoQC 
#bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($GUPPY_JOB)" -e ${LOG_DIR}/pycoQC.err -o ${LOG_DIR}/pycoQC.log -J ${LIBRARY}_pycoqc bash scr/pycoqc.sh --summary_file=${LIB_PATH}/guppy/ --out_html=${LIB_PATH}/QC/${SAMPLE}_pycoQC.html --title=${SAMPLE}


#Trim adapters
TRIM_JOB=${SAMPLE}_trim
bsub -n 8 -R "rusage[mem=64G]" -q verylong -e ${LOG_DIR}/trim.err -o ${LOG_DIR}/trim.log -J ${TRIM_JOB} bash scr/trimming.sh --fastq_dir=${FASTQ_DIR} --out_dir=${LIB_PATH}/fastq --sample=${SAMPLE} --porechop_path=${PORECHOP_PATH} --threads=8 


#Align fastq file
ALIGN_JOB=${SAMPLE}_align
bsub -n 32 -R "rusage[mem=64G]" -q verylong -w "done($TRIM_JOB)" -e ${LOG_DIR}/align.err -o ${LOG_DIR}/align.log -J ${ALIGN_JOB} bash scr/alignment_dna.sh --fastq=${LIB_PATH}/fastq/${SAMPLE}_adapter_trimmed.fastq.gz --out_dir=${LIB_PATH}/bam --sample=${SAMPLE} --threads=32 --reference=${MMI_HG19}

#Coverage
COVERAGE_JOB=${SAMPLE}_coverage
cd ${LIB_PATH}/coverage && bsub -n 2 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -e ${LOG_DIR}/coverage.err -o ${LOG_DIR}/coverage.log -J ${COVERAGE_JOB} "mosdepth -n --by ${TARGETS} --fast-mode ${SAMPLE} ${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam"

cd /b06x-isilon/b06x-m/mnp_nanopore/git_repos/Rapid-CNS2/
#Call CNVs
CNV_JOB=${SAMPLE}_cnv
bsub -n 16 -R "rusage[mem=64G]" -q long -w "done($ALIGN_JOB)" -e ${LOG_DIR}/cnv.err -o ${LOG_DIR}/cnv.log -J ${CNV_JOB} bash scr/cnvpytor.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/cnv --sample=${SAMPLE} --threads=16

#Deepvariant
DEEPVARIANT_JOB=${SAMPLE}_deepvariant
bsub -n 16 -R "rusage[mem=64G]" -q verylong -w "done($ALIGN_JOB)" -J ${DEEPVARIANT_JOB} bash scr/deepvariant.sh  --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/deepvariant --reference=${REFERENCE_HG19} --sample=${SAMPLE} --threads=16 --path=${DEEPVARIANT_PATH}
DEEPVARIANT_ANNO=${SAMPLE}_deepvariant_annovar
bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($DEEPVARIANT_JOB)" -J ${DEEPVARIANT_ANNO} -e ${LOG_DIR}/deepvariant_annovar.err -o ${LOG_DIR}/deepvariant_annovar.log bash scr/deepvariant_annovar.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/deepvariant --annovar_path=${ANNOVAR_PATH} --annovar_db=${ANNOVAR_DB} --panel_bed=${PANEL} --reference=${REFERENCE_HG19} --sample=${SAMPLE}

#Variant and SV calling
bsub -n 2 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -J ${SAMPLE}_svim -e ${LOG_DIR}/svim_trimmed.err -o ${LOG_DIR}/svim_trimmed.log bash scr/svim.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/svim --reference=${REFERENCE_HG19} --sample=${SAMPLE}

LONGSHOT_JOB=${SAMPLE}_longshot
bsub -n 2 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -J ${LONGSHOT_JOB} -e ${LOG_DIR}/longshot_trimmed.err  -o ${LOG_DIR}/longshot_trimmed.log bash scr/longshot.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/longshot --annovar_path=${ANNOVAR_PATH} --annovar_db=${ANNOVAR_DB} --panel_bed=${PANEL} --reference=${REFERENCE_HG19} --sample=${SAMPLE}

bsub -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -J ${SAMPLE}_special_positions -e ${LOG_DIR}/special_pos.err -o ${LOG_DIR}/special_positions.log bash scr/special_positions.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/special_positions/ --reference=${REFERENCE_HG19} --sample=${SAMPLE}

#megalodon modified basecalling
MEGALODON_DIR=${LIB_PATH}/megalodon_hg38/
#MEGALODON_JOB=${SAMPLE}_megalodon
#bsub -gpu num=1:j_exclusive=yes:mode=exclusive_process:gmem=20G -q gpu -J ${MEGALODON_JOB} bash scr/megalodon.sh --fast5_dir=${FAST5_DIR} --out_dir=${MEGALODON_DIR} --guppy_path=${GUPPY_PATH} --reference_file=${MMI_HG38}

#MGMT
MGMT_JOB=${SAMPLE}_MGMT
MGMT_PRED=${SAMPLE}_MGMT_Pred
bsub -R "rusage[mem=24G]" -q verylong -J ${MGMT_JOB} bash scr/mgmt_sites.sh --megalodon_dir=${MEGALODON_DIR} --mgmt_bed=${MGMT_BED} --reference_file=${MMI_HG38} --guppy_path=${GUPPY_PATH}
conda activate classifyByMethylation && bsub -R  "rusage[mem=24G]" -q long -w "done($MGMT_JOB)" -J ${MGMT_PRED} -e ${LOG_DIR}/mgmt_pred.err -o ${LOG_DIR}/mgmt_pred.log Rscript scr/mgmt_pred.R --input=${MEGALODON_DIR}/mgmt_megalodon.bed --out_dir=${MEGALODON_DIR} --probes=${MGMT_PROBES} --model=${MGMT_MODEL} --sample=$SAMPLE 

#Methylation classification
MC_JOB=${SAMPLE}_methylation_classification
MC_DIR=${LIB_PATH}/methylation_classification/
conda activate classifyByMethylation && bsub -n 4 -R "rusage[mem=64G]" -q verylong -J ${MC_JOB} -e ${LOG_DIR}/methylation_classification.err -o ${LOG_DIR}/methylation_classification.log Rscript scr/methylation_classification_nanodx.R --sample=${SAMPLE} --out_dir=${MC_DIR} --megalodon_dir=${MEGALODON_DIR} --probes_file=${PROBES} --training_data=${TRAINING_DATA} --threads=4 --array_file=${ARRAY_FILE}

DEEPVARIANT_REPORT=${SAMPLE}_DV_REPORT
LONGSHOT_REPORT=${SAMPLE}_LONGSHOT_REPORT
bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($DEEPVARIANT_ANNO)" -J ${DEEPVARIANT_REPORT} -e ${LOG_DIR}/deepvariant_report.err -o ${LOG_DIR}/deepvariant_report.log Rscript scr/filter_report.R --input=${LIB_PATH}/deepvariant/${SAMPLE}_deepvariant_panel.hg19_multianno.csv --output=${LIB_PATH}/deepvariant/${SAMPLE}_deepvariant_report.csv --sample=${SAMPLE} 
bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($LONGSHOT_JOB)" -J ${LONGSHOT_REPORT} -e ${LOG_DIR}/longshot_report.err -o ${LOG_DIR}/longshot_report.log Rscript scr/filter_report.R --input=${LIB_PATH}/longshot/${SAMPLE}_longshot_panel.hg19_multianno.csv --output=${LIB_PATH}/longshot/${SAMPLE}_longshot_report.csv --sample=${SAMPLE} 

#Report
cd scr/ && bsub -n 4 -R "rusage[mem=64G]" -q verylong -J ${SAMPLE}_longshot_report -w "done($COVERAGE_JOB) && done($MGMT_PRED) && done($MC_JOB) && done($LONGSHOT_REPORT) && done($CNV_JOB)" -e ${LOG_DIR}/longshot_report.err -o ${LOG_DIR}/longshot_report.log Rscript make_report.R --rf_details=${MC_DIR}/${SAMPLE}_rf_details.tsv --votes=${MC_DIR}/${SAMPLE}_votes.tsv --sample=${SAMPLE} --mutations=${LIB_PATH}/longshot/${SAMPLE}_longshot_report.csv --cnv_plot=${LIB_PATH}/cnv/${SAMPLE}_cnvpytor_100k.global.0000.png --coverage=${LIB_PATH}/coverage/${SAMPLE}.mosdepth.summary.txt --output_dir=${LIB_PATH}/report/ --prefix=${SAMPLE}_longshot --patient='Jane Doe'

bsub -n 4 -R "rusage[mem=64G]" -q verylong -J ${SAMPLE}_deepvariant_report -w "done($COVERAGE_JOB) && done($MGMT_PRED) && done($MC_JOB) && done($DEEPVARIANT_REPORT) && done($CNV_JOB)" -e ${LOG_DIR}/deepvariant_report.err -o ${LOG_DIR}/deepvariant_report.log Rscript make_report.R --rf_details=${MC_DIR}/${SAMPLE}_rf_details.tsv --votes=${MC_DIR}/${SAMPLE}_votes.tsv --sample=${SAMPLE} --mutations=${LIB_PATH}/deepvariant/${SAMPLE}_deepvariant_report.csv --cnv_plot=${LIB_PATH}/cnv/${SAMPLE}_cnvpytor_100k.global.0000.png --coverage=${LIB_PATH}/coverage/${SAMPLE}.mosdepth.summary.txt --output_dir=${LIB_PATH}/report/ --prefix=${SAMPLE}_deepvariant --patient='Jane Doe'


