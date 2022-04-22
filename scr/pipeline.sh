FASTQ_FILE=$1
LIB_PATH=$2
SAMPLE=$3

REFERENCE=/b06x-isilon/b06x-m/mnp_nanopore/analysis/hg19.mmi
CODE_LIB=/b06x-isilon/b06x-m/mnp_nanopore/rapid_cns2/scr
ANNOVAR_DB=/b06x-isilon/b06x-m/mnp_nanopore/software/humandb/
ANNOVAR_PATH=/b06x-isilon/b06x-m/mnp_nanopore/software/annovar/annovar/
PANEL=/b06x-isilon/b06x-m/mnp_nanopore/rapid_cns2/NPHD_panel.bed 

REF=/b06x-isilon/b06x-m/mnp_nanopore/software/hg19/hg19.fa

mkdir -p ${LIB_PATH}
mkdir -p ${LIB_PATH}/logs/
mkdir -p ${LIB_PATH}/bam/
mkdir -p ${LIB_PATH}/cnv/
mkdir -p ${LIB_PATH}/deepvariant/
mkdir -p ${LIB_PATH}/longshot/
mkdir -p ${LIB_PATH}/annovar/
mkdir -p ${LIB_PATH}/svim/
mkdir -p ${LIB_PATH}/special_positions/


LOG_FOLDER=${LIB_PATH}/logs
#Align fastq file
ALIGN_JOB=${SAMPLE}_align
bsub -n 8 -R "rusage[mem=32G]" -q long -e ${LOG_FOLDER}/align.err -o ${LOG_FOLDER}/align.log -J ${ALIGN_JOB} bash ${CODE_LIB}/alignment_dna.sh --fastq=${FASTQ_FILE} --out_dir=${LIB_PATH}/bam --sample=${SAMPLE} --reference=${REFERENCE} --threads=8

#Call CNVs
CNV_JOB=${SAMPLE}_cnv
bsub -n 64 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -e ${LOG_FOLDER}/cnv.err -o ${LOG_FOLDER}/cnv.log -J ${CNV_JOB} bash ${CODE_LIB}/cnvpytor.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/cnv --sample=${SAMPLE} --threads=64

#Deepvariant
DEEPVARIANT_JOB=${SAMPLE}_deepvariant
bsub -n 64 -R "rusage[mem=24G]" -q verylong -w "done($ALIGN_JOB)" -J ${DEEPVARIANT_JOB} bash ${CODE_LIB}/deepvariant.sh  --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/deepvariant --reference=${REF} --sample=${SAMPLE} --threads=64 --path=/b06x-isilon/b06x-m/mnp_nanopore/software/pepper_deepvariant_r0.4.sif

bsub -n 2 -R "rusage[mem=20G]" -q long -w "done($DEEPVARIANT_JOB)" -J ${LIBRARY}_deepvariant_annovar -e ${LOG_DIR}/deepvariant_annovar.err -o ${LOG_DIR}/deepvariant_annovar.log bash ${CODE_LIB}/deepvariant_annovar.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/deepvariant --annovar_path=${ANNOVAR_PATH} --annovar_db=${ANNOVAR_DB} --panel_bed=${PANEL} --reference=${REFERENCE} --sample=${SAMPLE}

#Variant and SV calling
bsub -n 2 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_svim -e ${LOG_FOLDER}/svim_trimmed.err -o ${LOG_FOLDER}/svim_trimmed.log bash ${CODE_LIB}/svim.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/svim --reference=${REF} --sample=${SAMPLE}

bsub -n 2 -R "rusage[mem=32G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_longshot -e ${LOG_FOLDER}/longshot_trimmed.err  -o ${LOG_FOLDER}/longshot_trimmed.log bash ${CODE_LIB}/longshot.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/longshot --annovar_path=${ANNOVAR_PATH} --annovar_db=${ANNOVAR_DB} --panel_bed=${PANEL} --reference=${REF} --sample=${SAMPLE}
  
bsub -R "rusage[mem=20G]" -q long -w "done($ALIGN_JOB)" -J ${LIBRARY}_special_pos -e ${LOG_FOLDER}/special_pos.err -o ${LOG_FOLDER}/special_pos.log bash ${CODE_LIB}/special_positions.sh --bam_file=${LIB_PATH}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam --out_dir=${LIB_PATH}/svim --reference=${REF} --sample=${SAMPLE}


