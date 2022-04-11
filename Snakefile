report: "report/{sample}_workflow.rst"
configfile: "rapid_cns_snake.yaml"
OUTDIR = os.path.abspath(config["outdir"])
GUPPY_SERVER=config["guppy"] + "/guppy_basecall_server"

rule megalodon:
    input:
        config["FAST5_dir"]
    output:
        out_dir=OUTDIR+"/megalodon/",
        out_file=OUTDIR+"/megalodon/modified_bases.5mC.bed"
    resources:
        nvidia_gpu=1,
        mem_gb=64
    conda:
        "envs/rapid_cns.yml"
    params:
        guppy=config["guppy"],
        ref=config["ref_hg38_mmi"]
    shell:
        "export GUPPY_SERVER={params.guppy}/guppy_basecall_server && megalodon {input} --outputs mods mappings --overwrite --reference {params.ref} --mod-motif m CG 0 --output-directory {output.out_dir} --guppy-server-path ${GUPPY_SERVER} --overwrite --write-mods-text --devices 0 --processes 40 --guppy-params '--num_callers 8 --gpu_runners_per_device 8  --chunks_per_runner 2048' "

rule mgmt_bed:
    input:
        in_file=OUTDIR+"/megalodon/modified_bases.5mC.bed"
    params:
        config["mgmt_hg38"]
    conda:
        "envs/rapid_cns.yml"
    output:
        out_file=OUTDIR+"/mgmt/{sample}_mgmt.bed"
    shell:
        "bedtools intersect -a {input.in_file} -b {params} > {output.out_file}"



rule methylation_classification:
    input:
        in_file=OUTDIR+"/megalodon/modified_bases.5mC.bed"
    params:
        probes=config["probes"],
        array=config["array"],
        training_data=config["training_data"],
        out_dir=OUTDIR+"/methylation_classification"
    threads: 16
    resources:
        mem_gb=64
    conda:
        "envs/methylation_classification.yml"
    log:
        "logs/{sample}_methylation_classification.log"
    output:
        out_file=OUTDIR+"/methylation_classification/{sample}_votes.tsv"
    script:
        "scripts/methylation_classification.R --sample={sample} --out_dir={params.out_dir} --methylation_file={input.in_file} --probes_file={params.probes} --array_file={params.array} --training_data={params.training_data} --threads={threads}"


if config["basecalling"]:
#Basecalling
    rule basecall:
        input:
            config["FAST5_dir"]
        params:
            dir=OUTDIR+"/guppy",
            guppy=config["guppy"]
        output:
            fastq=OUTDIR+"/fastq/{sample}_pass.fastq.gz"
        resources:
            nvidia_gpu=1,
            mem_gb=24
        threads: 8
        conda:
            "envs/rapid_cns.yml"
        shell:
            "scripts/guppy_dna.sh --fast5_dir={input} --guppy_path={params.guppy} --out_dir={params.dir} --out_fastq={output.fastq}"

    rule QC:
        input:
            OUTDIR+"guppy/sequencing_summary.txt"
        conda:
            "envs/rapid_cns.yml"
        output:
            OUTDIR+"/QC/{sample}_pycoQC.html"
        shell:
            "scripts/pycoqc.sh --summary_file={input} --out_html={output} --title={sample}"

    rule basecall_trimming:
        input:
            OUTDIR+"/fastq/{sample}_pass.fastq.gz"
        output:
            OUTDIR+"/fastq/{sample}_adapter_trimmed.fastq.gz"
        params:
            config["porechop"]
        log:
            OUTDIR+"/logs/{sample}_trimming.log"
        threads: 32
        resources:
            mem_gb=64
        conda:
            "envs/rapid_cns.yml"
        shell:
            "python3 {params}/porechop-runner.py -i {input} -o {output} -t {threads} --verbosity 3"

else:
    rule trimming:
        input:
            config["fastq"]
        output:
            OUTDIR+"/fastq/{sample}_adapter_trimmed.fastq.gz"
        log:
            OUTDIR+"/logs/{sample}_trimming.log"
        params:
            config["porechop"]
        threads: 32
        resources:
            mem_gb=64
        conda:
            "envs/rapid_cns.yml"
        shell:
            "python3 {params}/porechop-runner.py -i {input} -o {output} -t {threads} --verbosity 3"

rule minimap2_align:
    input:
        fastq=OUTDIR+"/fastq/{sample}_adapter_trimmed.fastq.gz"
    output:
        OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    log:
        OUTDIR+"/logs/{sample}_align.log"
    params:
        mmi=config["ref_hg19_mmi"],
        out_dir=OUTDIR+"/bam/"
    threads: 16
    resources:
        mem_gb=32
    conda:
        "envs/rapid_cns.yml"
    shell:
        "scripts/alignment_dna.sh --fastq={input.fastq} --out_dir={params.out_dir} --sample={wildcards.sample} --reference={params.mmi} --threads={threads}"

rule longshot_variants:
    input:
        bam=OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        annovar_path=config["annovar_path"],
        annovar_db=config["annovar_db"],
        ref=config["ref_hg19_fa"],
        panel=config["panel"],
        dir=OUTDIR+"/longshot"
    output:
        OUTDIR+"/longshot/{sample}_panel.hg19_multianno.csv"
    log:
        OUTDIR+"/logs/{sample}_longshot.log"
    resources:
        mem_gb=32
    conda:
        "envs/rapid_cns.yml"
    shell:
        "scripts/longshot.sh --bam_file={input.bam} --out_dir={params.dir} --annovar_path={params.annovar_path} --annovar_db={params.annovar_db} --panel_bed={params.panel} --reference={params.ref} --sample={wildcards.sample}"

rule filter_longshot:
    input:
        OUTDIR+"/longshot/{sample}_panel.hg19_multianno.csv"
    output:
        OUTDIR+"/longshot/{sample}_longshot_panel_filtered.csv"
    conda:
	      "envs/methylation_classification.yml"
    script:
        "scripts/filter_snps.R"

rule deepvariant_variants:
    input:
        bam=OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        ref=config["ref_hg19_fa"],
        out_dir=OUTDIR+"/deepvariant",
        container=config["deepvariant"]
    output:
        out_vcf=OUTDIR+"/deepvariant/{sample}.vcf.gz"
    resources:
        mem_gb=64
    threads: 64
    shell:
        "scripts/deepvariant.sh --bam_file={input.bam} --out_dir={params.out_dir} --reference={params.ref} --sample={wildcards.sample} --threads={threads} --path={params.container}"

rule deepvariant_annovar:
    input:
        out_dir=OUTDIR+"/deepvariant",
        in_vcf=OUTDIR+"/deepvariant/{sample}.vcf.gz"
    params:
        annovar_path=config["annovar_path"],
        annovar_db=config["annovar_db"],
        ref=config["ref_hg19_fa"],
        panel=config["panel"]
    output:
        OUTDIR+"/deepvariant/{sample}_deepvariant_panel.hg19_multianno.csv"
    shell:
        "scripts/deepvariant_annovar.sh --out_dir={input.out_dir} --annovar_path={params.annovar_path} --annovar_db={params.annovar_db} --panel_bed={params.panel} --reference={params.ref} --sample={wildcards.sample}"

rule filter_deepvariant:
    input:
        OUTDIR+"/deepvariant/{sample}_deepvariant_panel.hg19_multianno.csv"
    output:
        OUTDIR+"/deepvariant/{sample}_deepvariant_panel_filtered.csv"
    conda:
      	"envs/methylation_classification.yml"
    script:
        "scripts/filter_snps.R"

rule special_positions:
    input:
        bam=OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    output:
        OUTDIR+"/special_positions/"
    params:
        ref=config["ref_hg19_fa"]
    conda:
      	"envs/rapid_cns.yml"
    log:
        OUTDIR+"/logs/special_positions.log"
    shell:
        "scripts/special_positions.sh --bam_file={bam} --out_dir={output} --reference={params.ref} --sample={wildcards.sample}"

rule copy_number:
    input:
        bam=OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    threads: 64
    params:
        out_dir=OUTDIR+"/cnv"
    output:
        OUTDIR+"/cnv/{sample}_cnvpytor_100k.png",
        OUTDIR+"/cnv/{sample}.cnvpytor.annotated.calls.1000.xlsx"
    log:
        OUTDIR+"/logs/{sample}_cnv.log"
    conda:
      	"envs/rapid_cns.yml"
    shell:
        "scripts/cnvpytor.sh --bam_file={input.bam} --out_dir={params.out_dir} --sample={wildcards.sample} --threads={threads}"

rule SV:
    input:
        bam=OUTDIR+"/bam/{sample}_cat.fastq.trimmed.minimap2.coordsorted.bam"
    params:
        ref=config["ref_hg19_fa"],
        out_dir=OUTDIR+"/svim"
    output:
        OUTDIR+"/svim/{sample}.trimmed/variants.vcf"
    log:
        OUTDIR+"/logs/{sample}_svim.log"
    resources:
        mem_gb=32
    conda:
        "envs/rapid_cns.yml"
    shell:
        "scripts/svim.sh --bam_file={input.bam} --out_dir={params.out_dir} --reference={params.ref} --sample={wildcards.sample}"
