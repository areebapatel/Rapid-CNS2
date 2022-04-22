for i in "$@"; do
  case $i in
    -b=*|--bam_file=*)
      BAM_FILE="${i#*=}"
      shift # sorted and indexed bam file
      ;;
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # CNV directory
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample
      ;;
    -t=*|--threads=*)
      THREADS="${i#*=}"
      shift # no. of threads
      ;;
  esac
done

mkdir -p ${OUT_DIR}
cd ${OUT_DIR}

cnvpytor -root ${SAMPLE}_CNV.pytor -rd ${BAM_FILE}
cnvpytor -root ${SAMPLE}_CNV.pytor -his 1000 10000 100000 -j ${THREADS}
cnvpytor -root ${SAMPLE}_CNV.pytor -partition 1000 10000 100000 -j ${THREADS}
cnvpytor -root ${SAMPLE}_CNV.pytor -call 1000 -j ${THREADS} > ${SAMPLE}.cnvpytor.calls.1000.tsv
cnvpytor -root ${SAMPLE}_CNV.pytor -call 10000 -j ${THREADS} > ${SAMPLE}.cnvpytor.calls.10000.tsv
cnvpytor -root ${SAMPLE}_CNV.pytor -call 100000 -j ${THREADS} > ${SAMPLE}.cnvpytor.calls.100000.tsv
cnvpytor -root ${SAMPLE}_CNV.pytor -plot manhattan 100000 -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 -o ${SAMPLE}_cnvpytor_100k.png

cp ${SAMPLE}_CNV.pytor file.pytor
cnvpytor -root file.pytor -view 1000 < annotate.spytor 
mv calls.1000.xlsx ${SAMPLE}.cnvpytor.annotated.calls.1000.xlsx
rm -f file.pytor
