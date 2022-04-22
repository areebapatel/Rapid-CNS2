#Activate virtualenv

for i in "$@"; do
  case $i in
    -f=*|--fast5_dir=*)
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
  esac
done

#Guppy run
${GUPPY_PATH}/guppy_basecaller --save_path $OUT_DIR --input_path $FAST5_DIR --compress_fastq --num_callers 8 --gpu_runners_per_device 8 --chunks_per_runner 2048 --config dna_r9.4.1_450bps_modbases_5mc_hac.cfg -x "auto" --min_qscore 7 --verbose_logs

