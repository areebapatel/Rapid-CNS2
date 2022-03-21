for i in "$@"; do
  case $i in
    -b=*|--bam_file=*)
      BAM_FILE="${i#*=}"
      shift # sorted and indexed bam file
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # library directory
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample
      ;;
    -t=*|--threads=*)
      THREADS="${i#*=}"
      shift # no. of threads
      ;;
      -p=*|--path=*)
      DEEPVARIANT_PATH="${i#*=}"
      shift # deepvariant singularity image path
      ;;
      -r=*|--reference=*)
      REFERENCE="${i#*=}"
      shift # reference
      ;;
  esac
done

mkdir -p ${OUT_DIR}
mkdir -p ${OUT_DIR}/tmp
cp ${REFERENCE} ${OUT_DIR}/tmp/
cp ${REFERENCE}.fai ${OUT_DIR}/tmp/
cp ${BAM_FILE} ${OUT_DIR}/tmp/
cp ${BAM_FILE}.bai ${OUT_DIR}/tmp/

NAME=${BAM_FILE##*/}
BAM=/data/tmp/${NAME}
REF=/data/tmp/hg19.fa
OUTPUT_DIR=/data/


singularity exec --bind ${OUT_DIR}:/data/  $DEEPVARIANT_PATH run_pepper_margin_deepvariant call_variant -b ${BAM} -f ${REF} -o ${OUTPUT_DIR} -p ${SAMPLE} -t ${THREADS} --ont

rm -r ${OUT_DIR}/tmp/
