
for i in "$@"; do
  case $i in
    -f=*|--fastq_dir=*)
      FASTQ_DIR="${i#*=}"
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
      ;;
     -g=*|--targets=*)
      TARGETS="${i#*=}"
      shift
      ;;
  esac
done

#Align FASTQ
BAM_FILE=${OUT_DIR}/${SAMPLE}_cat.fastq.minimap2.coordsorted.bam
mkdir -p ${OUT_DIR}

cd ${OUT_DIR}
mkdir tmp/
cat ${FASTQ_DIR}/* > tmp/pass_fastq.gz
minimap2 -ax map-ont --MD ${REFERENCE} tmp/pass_fastq.gz | samtools view -bS -@ ${THREADS} | samtools sort > ${BAM_FILE}

samtools index ${BAM_FILE}

bedtools intersect -a ${BAM_FILE} -b ${TARGETS} > ${OUT_DIR}/${SAMPLE}_cat.fastq.minimap2.coordsorted.ontarget.bam
samtools index ${OUT_DIR}/${SAMPLE}_cat.fastq.minimap2.coordsorted.ontarget.bam
rm -r tmp/

