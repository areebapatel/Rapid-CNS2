#/bin/bash

for i in "$@"; do
  case $i in
    -o=*|--out_dir=*)
      OUT_DIR="${i#*=}"
      shift # out dir
      ;;
    -a=*|--annovar_path=*)
      ANNOVAR_PATH="${i#*=}"
      shift # path to annovar
      ;;
    -p=*|--panel_bed=*)
      PANEL_BED="${i#*=}"
      shift # panel bed file
      ;;
     -d=*|--annovar_db=*)
      ANNOVAR_DB="${i#*=}"
      shift # path to annovar db files (humandb)
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample
      ;;
  esac
done




vcftools --gzvcf ${OUT_DIR}/${SAMPLE}.vcf.gz --remove-filtered-all --recode --stdout | gzip -c > ${OUT_DIR}/${SAMPLE}_PASS_only.vcf.gz
bedtools intersect -a ${OUT_DIR}/${SAMPLE}_PASS_only.vcf.gz -b $PANEL_BED > ${OUT_DIR}/${SAMPLE}_deepvariant_panel.vcf

cd ${OUT_DIR}
$ANNOVAR_PATH/convert2annovar.pl -format vcf4 ${SAMPLE}_deepvariant_panel.vcf -withfreq -includeinfo > ${SAMPLE}_deepvariant_panel.avinput

$ANNOVAR_PATH/table_annovar.pl ${SAMPLE}_deepvariant_panel.avinput ${ANNOVAR_DB} -buildver hg19 -out ${SAMPLE}_deepvariant_panel -protocol refGene,cytoBand,avsnp147,dbnsfp30a,1000g2015aug_eur,cosmic68 -operation gx,r,f,f,f,f -nastring . -csvout -polish -otherinfo
