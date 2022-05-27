#source paths.config
#CONDA_DIR=$CONDA_DIR

source /omics/groups/OE0146/internal/Areeba/miniconda3/etc/profile.d/conda.sh
conda activate rapid_cns_conda_env

for i in "$@"; do
  case $i in
    -f=*|--fast5_dir=*)
      FAST5_DIR="${i#*=}"
      shift # path to FAST5 files dir
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # megalodon results dir
      ;;
    -g=*|--guppy_path=*)
      GUPPY_PATH="${i#*=}"
      shift # path to guppy /ont-guppy/bin/
      ;;
    -r=*|--reference_file=*)
      REFERENCE_FILE="${i#*=}"
      shift # hg38 reference file
      ;;
  esac
done

export GUPPY_SERVER=${GUPPY_PATH}/guppy_basecall_server
 

#megalodon run command
megalodon ${FAST5_DIR} --outputs mods mappings --overwrite --reference ${REFERENCE_FILE} --mod-motif m CG 0 --output-directory ${OUT_DIR} --guppy-server-path ${GUPPY_SERVER} --overwrite --write-mods-text --devices 0 --processes 40 --guppy-params "--num_callers 8 --gpu_runners_per_device 8  --chunks_per_runner 2048" 

