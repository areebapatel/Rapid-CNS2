#/bin/bash
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

#TERTp mutations
samtools mpileup  -Q 7 -r chr5:1295228-1295228 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_TERT1.vcf
samtools mpileup  -Q 7  -r chr5:1295250-1295250 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_TERT2.vcf

#BRAF V600E mutation
samtools mpileup  -Q 7 -r chr7:140453135-140453137 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_BRAF_V600.vcf

#IDH1/2 mutations
samtools mpileup  -Q 7 -r chr2:209113111-209113113 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_IDH1_R132.vcf
samtools mpileup  -Q 7 -r chr15:90631837-90631839 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_IDH2_R172.vcf

#H3FA mutations
samtools mpileup -Q 7 -r chr1:226252134-226252136 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_H3F3A_K27.vcf
samtools mpileup -Q 7 -r chr1:226252155-226252157 -g -f $REFERENCE ${BAM_FILE} | bcftools view --no-header > ${OUT_DIR}/${SAMPLE}_H3FA_G34.vcf
