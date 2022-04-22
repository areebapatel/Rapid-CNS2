LIBRARY=$1
SAMPLE=$2
THREADS=$3
FASTQ=/mnp_nanopore/analysis/${LIBRARY}/fastq/${SAMPLE}_pass.fastq.gz
BAM=/mnp_nanopore/analysis/${LIBRARY}/bam/${SAMPLE}_cat.fastq.trimmed.minimap2.coordsorted.bam
REFERENCE=/mnp_nanopore/software/hg19/hg19.fa

mkdir -p /mnp_nanopore/analysis/${LIBRARY}/nanopolish

/nanopolish/nanopolish index -d /mnp_nanopore/data/${LIBRARY}/${SAMPLE}/*/fast5/ ${FASTQ}

/nanopolish/nanopolish call-methylation -t ${THREADS} -r ${FASTQ} -b ${BAM} -g ${REFERENCE} -w "chr10:131,264,949-131,265,710" > /mnp_nanopore/analysis/${LIBRARY}/nanopolish/methylation_calls_mgmt.tsv

python /nanopolish/scripts/calculate_methylation_frequency.py /mnp_nanopore/analysis/${LIBRARY}/nanopolish/methylation_calls_mgmt.tsv > /mnp_nanopore/analysis/${LIBRARY}/nanopolish/methylation_frequency_mgmt.tsv
