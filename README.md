## RAPID-CNS2 (LSF cluster) ##

This pipeline analyses CNS tumour data generated through Nanopore adaptive sequencing using [ReadFish](https://github.com/LooseLab/readfish). It requires FAST5 files generated from the sequencing run as input.

**Sequencing**

Sequencing using ReadFish on a MinION device is recommended on a workstation/notebook powered by a NVIDIA RTX2080 GPU.

Instructions (from ReadFish)
1. Install ReadFish
```
# Make a virtual environment
python3 -m venv readfish
. ./readfish/bin/activate
pip install --upgrade pip

# Install our ReadFish Software
pip install git+https://github.com/LooseLab/read_until_api_v2@master
pip install git+https://github.com/LooseLab/readfish@master
```

2. Download and edit the `reference` field in `read_until.toml`  
3. Load the flowcell and start sequencing on MinKNOW
4. Open terminal and start `guppy_basecall_server`

`guppy_basecall_server --config dna_r9.4.1_450bps_fast.cfg --port 5555 --device "cuda:0" --qscore_filtering`

3. Open new tab in terminal and run ReadFish

```
readfish targets --device <YOUR_DEVICE_ID> \
              --experiment-name "RU Test basecall and map" \
              --toml <PATH_TO_TOML> \
              --log-file ru_test.log
```

You should get outputs as

```
2020-02-24 16:45:35,677 ru.ru_gen 7R/0.03526s
2020-02-24 16:45:35,865 ru.ru_gen 3R/0.02302s
2020-02-24 16:45:35,965 ru.ru_gen 4R/0.02249s
```

If these times > 0.4s, targeting is not working as expected.


**RAPID-CNS2 analysis**
1. If you do not have an existing conda installation, follow these steps. If you have conda preinstalled, skip to step 2.
- Download the appropriate Miniconda installer [here](https://docs.conda.io/en/latest/miniconda.html#linux-installers)
- Open terminal, go to directory containing the Miniconda file. Enter
`bash Miniconda3-latest-Linux-x86_64.sh`

2. Install snakemake
```
conda install -n base -c conda-forge mamba
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
```

3. Install CNVpytor
 ```
git clone https://github.com/abyzovlab/CNVpytor.git
cd CNVpytor
pip install .
```  

4. Download GPU version of guppy [here](https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_5.0.7_linux64.tar.gz) (Registration required)
- Unpack the tar file (xxx is the version e.g. 4.2.2)
 `tar -xf ont-guppy_xxx_linux<64 or aarch64>.tar.gz`

5. Download singularity images for PEPPER-Margin-DeepVariant ` singularity pull docker://kishwars/pepper_deepvariant:r0.4`.

6. Download ANNOVAR [here](https://www.openbioinformatics.org/annovar/annovar_download_form.php)

7. Edit `rapid_cns_snake.config` to specify paths

8. Run pipeline as
 ```
 snakemake --directory=<PATH/TO/OUTPUT/DIRECTORY> --use-conda
 ```


**Requirements**
- Reference genome hg19 and hg38 FASTA
- ANNOVAR database.
```
annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/

annotate_variation.pl -buildver hg19 -downdb cytoBand humandb/

annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 humandb/

annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 humandb/

annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a humandb/
```
