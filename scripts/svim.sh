
#Activate virtualenv

for i in "$@"; do
  case $i in
    -b=*|--bam_file=*)
      BAM_FILE="${i#*=}"
      shift # past argument=value
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # output dir
      ;;
    -r=*|--reference=*)
      REFERENCE="${i#*=}"
      shift # hg19 fasta reference
      ;;
     -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample name
      ;;
  esac
done

mkdir -p ${OUT_DIR}

cd ${OUT_DIR}

svim alignment ${SAMPLE}_trimmed ${BAM_FILE} ${REFERENCE}

