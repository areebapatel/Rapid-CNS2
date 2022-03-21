#Activate virtualenv

for i in "$@"; do
  case $i in
    -d=*|--fast5_dir=*)
      FAST5_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -g=*|--guppy_path=*)
      GUPPY_PATH="${i#*=}"
      shift # past argument=value
      ;;
    -f=*|--out_fastq=*)
      OUT_FASTQ="${i#*=}"
      shift # past argument=value
      ;;
  esac
done

mkdir -p $OUT_DIR

#Guppy run
${GUPPY_PATH}/guppy_basecaller --save_path $OUT_DIR --input_path $FAST5_DIR --compress_fastq --num_callers 8 --gpu_runners_per_device 8 --chunks_per_runner 2048 --config dna_r9.4.1_450bps_modbases_dam-dcm-cpg_hac.cfg -x "auto" --qscore_filtering --min_qscore 5 --verbose_logs

cat $OUT_DIR/fastq_pass/* > $OUT_FASTQ
