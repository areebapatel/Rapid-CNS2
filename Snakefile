report: "report/{sample}_workflow.rst"

rule megalodon:
    input:
        config["FAST5_dir"]
    output:
        out_dir=directory("megalodon")
        out_file="megalodon/modified_bases.5mC.bed"
    resources:
        nvidia_gpu=1
        mem_gb=64
    conda:
        "rapid_cns_conda_env"
    params:
        guppy=config["guppy"]
        ref=config["ref_hg38_fa"]
    shell:
        "export GUPPY_SERVER={params.guppy}/guppy_basecall_server && megalodon {input} --outputs mods mappings --overwrite --reference {params.ref} --mod-motif m CG 0 --output-directory {output.out_dir} --guppy-server-path ${GUPPY_SERVER} --overwrite --write-mods-text --devices 0 --processes 40 --guppy-params "--num_callers 8 --gpu_runners_per_device 8  --chunks_per_runner 2048" "

rule mgmt_bed:
    input:
        in_file="megalodon/modified_bases.5mC.bed"
    params:
        config["mgmt_hg38"]
    conda:
        "rapid_cns_conda_env"
    output:
        out_dir=directory("mgmt")
        out_file="mgmt/{sample}_mgmt.bed"
    shell:
        "bedtools intersect -a {input.in_file} -b {params} > {output.out_file}"

###To write mgmt predict script
rule mgmt_predict:
    input:
        in_file="mgmt/{sample}_mgmt.bed"
    params:
        mgmt_model=config["mgmt_model"]
    conda:
        "rapid_cns_conda_env"
    output:
        "mgmt/{sample}_mgmt_status.csv"
    script:
        "scripts/mgmt_predict.R"


rule methylation_classification:
    input:
        in_file="megalodon/modified_bases.5mC.bed"
    params:
        probes=config["probes"]
        array=config["array"]
        training_data=config["training_data"]
    threads: 16
    resources:
        mem_gb=64
    conda:
        "MethylationClassification"
    log:
        "logs/{sample}_methylation_classification.log"
    output:
        out_dir=directory("methylation_classification")
        out_file="methylation_classification/{sample}_votes.tsv"
    script:
        "scripts/methylation_classification.R --sample={sample} --out_dir={output.out_dir} --methylation_file={input.in_file} --probes_file={params.probes} --array_file={params.array} --training_data={params.training_data} --threads={threads}"


if config["basecalling"]:
#Basecalling
    rule basecall:
        input:
            config["FAST5_dir"]
        output:
            dir=directory("guppy")
            fastq=join(OUT_DIR,"fastq/{sample}_pass.fastq.gz")
            "guppy/sequencing_summary.txt"
        params:
            guppy=config["guppy"]
        resources:
            nvidia_gpu=1
            mem_gb=24
        threads: 8
        conda:
            "rapid_cns_conda_env"
        shell:
            "scripts/guppy_dna.sh --fast5_dir={input} --guppy_path={params.guppy} --out_dir={output.dir} --out_fastq={output.fastq}"

    rule QC:
        input:
            "guppy/sequencing_summary.txt"
        conda:
            "rapid_cns_conda_env"
        output:
            "QC/{sample}_pycoQC.html"
        shell:
            "scripts/pycoqc.sh --summary_file={input} --out_html={output} --title={sample}"

    rule basecall_trimming:
        input:
            "fastq/{sample}_pass.fastq.gz"
        output:
            "fastq/{sample}_adapter_trimmed.fastq.gz"
        params:
            config["porechop"]
        log:
            "logs/trimming.log"
        threads: 64
        resources:
            mem_gb=64
        conda:
            "rapid_cns_conda_env"
        shell:
            "python3 {params}/porechop-runner.py -i {input} -o {output} -t {threads} --verbosity 3"

else:
    rule trimming:
        input:
            config["fastq"]
        output:
            "fastq/{sample}_adapter_trimmed.fastq.gz"
        log:
            "logs/trimming.log"
        params:
            config["porechop"]
        threads: 64
        resources:
            mem_gb=64
        conda:
            "rapid_cns_conda_env"
        shell:
            "python3 {params}/porechop-runner.py -i {input} -o {output} -t {threads} --verbosity 3"

rule minimap2_align:
    input:
        fastq="fastq/{sample}_adapter_trimmed.fastq.gz"
    output:
        "bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    log:
        "logs/align.log"
    params:
        mmi=config["ref_hg19_mmi"]
    threads: 16
    resources:
        mem_gb=32
    conda:
        "rapid_cns_conda_env"
    shell:
        "scripts/alignment_dna.sh --fastq={input.fastq} --out_dir=lib_path/bam --sample={sample} --reference={params.mmi} --threads={threads}"

rule longshot_variants:
    input:
        bam="bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        annovar_path=config["annovar_path"]
        annovar_db=config["annovar_db"]
        ref=config["ref_hg19_fa"]
        panel=config["panel"]
    output:
        dir=directory("longshot")
        "longshot/{sample}_panel.hg19_multianno.csv"
    log:
        "out_path/logs/longshot.log"
    resources:
        mem_gb=32
    conda:
        "rapid_cns_conda_env"
    shell:
        "scripts/longshot.sh --bam_file={input.bam} --out_dir={output.dir} --annovar_path={params.annovar_path} --annovar_db={params.annovar_db} --panel_bed={params.panel} --reference={params.ref} --sample={sample}"

rule filter_longshot:
    input:
        "longshot/{sample}_panel.hg19_multianno.csv"
    output:
        "longshot/{sample}_longshot_panel_filtered.csv"
    scripts:
        "scripts/filter_snps.R"

rule deepvariant_variants:
    input:
        bam="bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        ref=config["ref_hg19_fa"]
        container=config["deepvariant"]
    output:
        out_dir=directory("deepvariant")
        out_vcf="deepvariant/{sample}.vcf.gz"
    resources:
        mem_gb=64
    threads: 64
    shell:
        "scripts/deepvariant.sh --bam_file={input.bam} --out_dir={output.out_dir} --reference={params.ref} --sample={sample} --threads={threads} --path={params.container}"

rule deepvariant_annovar:
    input:
        out_dir=directory("deepvariant")
        in_vcf="deepvariant/{sample}.vcf.gz"
    params:
        annovar_path=config["annovar_path"]
        annovar_db=config["annovar_db"]
        ref=config["ref_hg19_fa"]
        panel=config["panel"]
    output:
        "deepvariant/{sample}_deepvariant_panel.hg19_multianno.csv"
    shell:
        "scripts/deepvariant_annovar.sh --out_dir={input.out_dir} --annovar_path={params.annovar_path} --annovar_db={params.annovar_db} --panel_bed={params.panel} --reference={params.ref} --sample={sample}"

rule filter_deepvariant:
    input:
        "deepvariant/{sample}_deepvariant_panel.hg19_multianno.csv"
    output:
        "deepvariant/{sample}_deepvariant_panel_filtered.csv"
    scripts:
        "scripts/filter_snps.R"

rule special_positions:
    input:
        bam="bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    output:
        directory("special_positions")
    params:
        ref=config["ref_hg19_fa"]
    log:
        "logs/{sample}_special_positions.log"
    shell:
        "scripts/special_positions.sh --bam_file={bam} --out_dir={output} --reference={params.ref} --sample={sample}"

rule copy_number:
    input:
        bam="bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    threads: 64
    output:
        out_dir=directory("cnv")
        "cnv/{sample}_cnvpytor_100k.png"
        "cnv/{sample}.cnvpytor.annotated.calls.1000.xlsx"
    log:
        "logs/{sample}_cnv.log"
    shell:
        "scripts/cnvpytor.sh --bam_file={bam} --out_dir={output.out_dir} --sample={sample} --threads={threads}"

rule SV:
    input:
        bam="bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        ref=config["ref_hg19_fa"]
    output:
        out_dir=directory(svim")
        "svim/{sample.trimmed}/variants.vcf"
    log:
        "logs/{sample}_svim.log"
    resources:
        mem_gb=32
    conda:
        "rapid_cns_conda_env"
    shell:
        "scripts/svim.sh --bam_file={input.bam} --out_dir={output.out_dir} --reference={params.ref} --sample={sample}"
