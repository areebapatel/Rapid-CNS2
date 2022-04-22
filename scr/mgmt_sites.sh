
#!/usr/bin/bash/

for i in "$@"; do
  case $i in
    -m=*|--megalodon_dir=*)
      MEGALODON_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -b=*|--mgmt_bed=*)
      MGMT_BED="${i#*=}"
      shift # past argument=value
      ;;
  esac
done


bedtools intersect -a ${MEGALODON_DIR}/modified_bases.5mC.bed -b ${MGMT_BED} > ${MEGALODON_DIR}/mgmt_megalodon.bed
