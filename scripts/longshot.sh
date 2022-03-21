

for i in "$@"; do
  case $i in
    -b=*|--bam_file=*)
      BAM_FILE="${i#*=}"
      shift # bam file
      ;;
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
    -r=*|--reference=*)
      REFERENCE="${i#*=}"
      shift # hg19 fasta reference
      ;;
    -s=*|--sample=*)
      SAMPLE="${i#*=}"
      shift # sample
      ;;
  esac
done

#Call variants
LONGSHOT_VCF=${OUT_DIR}/${SAMPLE}_longshot.vcf

longshot -F --bam ${BAM_FILE} --ref ${REFERENCE} --out ${LONGSHOT_VCF}

#Subset panel variants
bedtools intersect -a ${LONGSHOT_VCF} -b $PANEL_BED > ${OUT_DIR}/${SAMPLE}_longshot_panel.vcf

#Annotate variants using annovar
cd ${OUT_DIR}

${ANNOVAR_PATH}/convert2annovar.pl -format vcf4 ${SAMPLE}_longshot_panel.vcf -withfreq -includeinfo > ${SAMPLE}_longshot_panel.avinput

${ANNOVAR_PATH}/table_annovar.pl ${SAMPLE}_longshot_panel.avinput ${ANNOVAR_DB} -buildver hg19 -out ${SAMPLE}_longshot_panel  -protocol refGene,cytoBand,avsnp147,dbnsfp30a,1000g2015aug_eur,cosmic68 -operation gx,r,f,f,f,f -nastring . -csvout -polish -otherinfo



