# Amplicon analysis pipeline

<div align=center><img width="1000" height="150" src="docs/dag.svg"/></div>


## Installation

### Basic environment

```bash
➤ mkdir -p ~/.conda/envs
➤ wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
➤ bash Mambaforge-Linux-x86_64.sh
# set the install path to ~/.conda/envs/mambaforge

# then activate mambaforge
➤ conda activate mambaforge

# install snakemake
➤ conda install -c bioconda -c conda-forge snakemake fd-find seqkit
```

### Set PYTHONPATH for qiimepi

```bash
➤ echo "export PYTHONPATH=/path/to/qiimepi:$PYTHONPATH" >> ~/.bashrc
# relogin
```

## Overview

```bash
➤ conda activate mambaforge
➤ python /path/to/qiimepi/run_qiimepi.py --help

usage: qiimepi [-h] [-v]  ...

     ██████╗ ██╗██╗███╗   ███╗███████╗██████╗ ██╗
    ██╔═══██╗██║██║████╗ ████║██╔════╝██╔══██╗██║
    ██║   ██║██║██║██╔████╔██║█████╗  ██████╔╝██║
    ██║▄▄ ██║██║██║██║╚██╔╝██║██╔══╝  ██╔═══╝ ██║
    ╚██████╔╝██║██║██║ ╚═╝ ██║███████╗██║     ██║
     ╚══▀▀═╝ ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝

        Omics for All, Open Source for All

    Quantitative Insights Into Microbial Ecology


optional arguments:
  -h, --help     show this help message and exit
  -v, --version  print software version and exit

available subcommands:

    init           init project
    amplicon_wf    amplicon data analysis pipeline using QIIME2
```

## Real world

### Step_0: Activate conda environment

```bash
# for snakemake
➤ conda activate mambaforge
```

### Step_1: download test data

```bash
➤ mkdir -p test
➤ cd test
➤ wget -c https://mothur.s3.us-east-2.amazonaws.com/wiki/miseqsopdata.zip
➤ unzip miseqsopdata.zip
➤ gzip MiSeq_SOP/*.fastq
```

### Step 2: Samples sheet

```bash
➤ fd fastq.gz /full/path/to/MiSeq_SOP | \
  sort | uniq | paste - - | \
  awk -F'[/_]' \
  'BEGIN {print "sample-id\tforward-absolute-filepath\treverse-absolute-filepath"};{print $(NF-4) "\t" $0}' \
  > samples.tsv
```

### Step 3: Init

```bash
➤ cd test
➤ python /path/to/qiimepi/run_qiimepi.py init -d . -s samples.tsv

➤ ll
config.yaml
envs
profiles
results
samples.miseq_sop.tsv
```

### Step 4: update config.yaml

```bash
➤ cat config.yaml

params:
  samples: "samples.tsv"
  metadata: "samples_metadata.tsv"

  # https://docs.qiime2.org/2021.11/tutorials/importing/
  import:
    type: "SampleData[PairedEndSequencesWithQuality]"
    # EMPSingleEndSequences
    # EMPPairedEndSequences
    # MultiplexedSingleEndBarcodeInSequence
    # MultiplexedPairedEndBarcodeInSequence
    # SampleData[SequencesWithQuality]
    # SampleData[PairedEndSequencesWithQuality]
    # FeatureTable[Frequency]
    # Phylogeny[Unrooted]

    format: "PairedEndFastqManifestPhred33V2"
    # CasavaOneEightSingleLanePerSampleDirFmt
    # SingleEndFastqManifestPhred33V2
    # SingleEndFastqManifestPhred64V2
    # PairedEndFastqManifestPhred33V2
    # PairedEndFastqManifestPhred64V2
    # BIOMV100Format
    # BIOMV210Format

  denoise:
    threads: 8
    dada2:
      do: True
      paired:
        trunc_len_f: 280
        trunc_len_r: 250
        trim_left_f: 0
        trim_left_r: 0
      single:
        trunc_len: 120
        trim_left: 0
    deblur:
      do: False
      trim_len: 280
      left_trim_len: 0

  taxonomic:
    threads: 8
    classifier: /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/silva-138-99-nb-classifier.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/silva-138-99-515-806-nb-classifier.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/silva-138-99-nb-classifier.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/silva-138-99-nb-weighted-classifier.qza

    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/gg_2022_10_backbone_full_length.nb.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/gg_2022_10_backbone.v4.nb.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/gg-13-8-99-515-806-nb-weighted-classifier.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/taxonomic_classifier/gg-13-8-99-nb-weighted-classifier.qza

  phylotree:
    threads: 8
    sepp_db: /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/sepp_reference_databases/sepp-refs-silva-128.qza
    # /home/jiezhu/databases/ecogenomics/QIIME2/2023.9/sepp_reference_databases/sepp-refs-gg-13-8.qza

  function:
    threads: 8


output:
  tmp: "results/tmp"
  import: "results/00.import"
  denoise: "results/01.denoise"
  taxonomic: "results/02.taxonomic"
  phylotree: "results/03.phylotree"
  function: "results/04.function"


envs:
  qiime2: "envs/qiime2.yaml"
  picrust2: "envs/picrust2.yaml"
```

### Step 5: Dry run amplicon_wf

```bash
➤ python /path/to/qiimepi/run_qiimepi.py amplicon_wf all --use-conda --dry-run

Job stats:
job                                            count    min threads    max threads
-------------------------------------------  -------  -------------  -------------
all                                                1              1              1
qiime2_denoise_dada2                               1              8              8
qiime2_denoise_dada2_export                        1              1              1
qiime2_denoise_dada2_visualization                 1              1              1
qiime2_denoise_dada2_visualization_export          1              1              1
qiime2_feature_table_export                        1              1              1
qiime2_feature_table_summarize                     1              1              1
qiime2_feature_table_tabulate                      1              1              1
qiime2_feature_table_tabulate_export               1              1              1
qiime2_function_picrust2                           1              8              8
qiime2_function_picrust2_add_descriptions          1              1              1
qiime2_import                                      1              1              1
qiime2_import_summarize                            1              1              1
qiime2_import_summarize_export                     1              1              1
qiime2_phylotree_align                             1              8              8
qiime2_phylotree_align_export                      1              1              1
qiime2_phylotree_align_visualization               1              1              1
qiime2_phylotree_align_visualization_export        1              1              1
qiime2_phylotree_sepp                              1              8              8
qiime2_phylotree_sepp_export                       1              1              1
qiime2_taxonomic_barplot                           1              1              1
qiime2_taxonomic_barplot_export                    1              1              1
qiime2_taxonomic_classification                    1              8              8
qiime2_taxonomic_classification_export             1              1              1
qiime2_taxonomic_krona                             1              1              1
qiime2_taxonomic_krona_export                      1              1              1
qiime2_taxonomic_visualization                     1              1              1
qiime2_taxonomic_visualization_export              1              1              1
total                                             28              1              8
```

### Step 6: Wet run amplicon_wf

```bash
➤ python /path/to/qiimepi/run_qiimepi.py \
  amplicon_wf all \
  --use-conda \
  --run-local \
  --jobs 10 \
  --cores 10
```

### Step 7: Check results

```bash
➤ tree results

results/
├── 00.import
│   ├── demux.qza
│   └── demux.qzv
├── 01.denoise
│   ├── dada2
│   │   ├── denoise_stats.qza
│   │   ├── denoise_stats_qza
│   │   │   └── stats.tsv
│   │   ├── denoise_stats.qzv
│   │   ├── rep_seqs.qza
│   │   ├── rep_seqs_qza
│   │   │   └── dna-sequences.fasta
│   │   ├── rep_seqs.qzv
│   │   ├── table.qza
│   │   ├── table_qza
│   │   │   ├── feature-table.biom
│   │   │   └── feature-table.tsv
│   │   └── table.qzv
├── 02.taxonomic
│   ├── dada2
│   │   ├── krona.qzv
│   │   ├── taxonomy_barplot.qzv
│   │   ├── taxonomy.qza
│   │   ├── taxonomy_qza
│   │   │   └── taxonomy.tsv
│   │   └── taxonomy.qzv
├── 03.phylotree
│   ├── dada2
│   │   ├── align
│   │   │   ├── alignment.qza
│   │   │   ├── empress_tree.qzv
│   │   │   ├── masked_alignment.qza
│   │   │   ├── rooted_tree.qza
│   │   │   ├── rooted_tree_qza
│   │   │   │   └── tree.nwk
│   │   │   ├── tree.qza
│   │   │   └── tree_qza
│   │   │       └── tree.nwk
│   │   └── sepp
│   │       ├── tree_placements.qza
│   │       ├── tree_placements_qza
│   │       │   └── placements.json
│   │       ├── tree.qza
│   │       └── tree_qza
│   │           └── tree.nwk
├── 04.function
│   ├── dada2
│   │   └── picrust2
│   │       ├── done
│   │       ├── done_description
│   │       ├── EC_metagenome_out
│   │       │   ├── pred_metagenome_contrib.tsv.gz
│   │       │   ├── pred_metagenome_unstrat_descrip.tsv.gz
│   │       │   ├── pred_metagenome_unstrat.tsv.gz
│   │       │   ├── seqtab_norm.tsv.gz
│   │       │   └── weighted_nsti.tsv.gz
│   │       ├── EC_predicted.tsv.gz
│   │       ├── KO_metagenome_out
│   │       │   ├── pred_metagenome_contrib.tsv.gz
│   │       │   ├── pred_metagenome_unstrat_descrip.tsv.gz
│   │       │   ├── pred_metagenome_unstrat.tsv.gz
│   │       │   ├── seqtab_norm.tsv.gz
│   │       │   └── weighted_nsti.tsv.gz
│   │       ├── KO_predicted.tsv.gz
│   │       ├── marker_predicted_and_nsti.tsv.gz
│   │       ├── out.tre
│   │       └── pathways_out
│   │           ├── path_abun_contrib.tsv.gz
│   │           ├── path_abun_unstrat_descrip.tsv.gz
│   │           └── path_abun_unstrat.tsv.gz

```

## Note

### [Sequence phred quality score](https://en.wikipedia.org/wiki/FASTQ_format)

```bash
➤ seqkit convert xx.fq.gz | head
```

Phred Score table
| Quality system name | Phred Score  | Coordinates                   |
| :-----------------: | :----------: | :---------------------------: |
| S - Sanger          |   Phred+33   |  raw reads typically (0, 40)  |
| X - Solexa          |   Solexa+64  |  raw reads typically (-5, 40) |
| I - Illumina 1.3+   |   Phred+64   |  raw reads typically (0, 40)  |
| J - Illumina 1.5+   |   Phred+64   |  raw reads typically (3, 41)  |
| L - Illumina 1.8+   |   Phred+33   |  raw reads typically (0, 41)  |
| P - PacBio          |   Phred+33   |  HiFi reads typically (0, 93) |

### [QIIME2 taxonomy database Version 2023.9](https://docs.qiime2.org/2022.11/data-resources)

#### Taxonomy classifiers for use with q2-feature-classifier

- [Silva 138 99% OTUs full-length sequences](https://data.qiime2.org/2023.9/common/silva-138-99-nb-classifier.qza)
- [Silva 138 99% OTUs from 515F/806R region of sequences](https://data.qiime2.org/2023.9/common/silva-138-99-515-806-nb-classifier.qza)
- [Greengenes 2022.10 full-length sequences](https://https://data.qiime2.org/classifiers/greengenes/gg_2022_10_backbone_full_length.nb.qza)
- [Greengenes 2022.10 from 515F/806R region of sequences](https://data.qiime2.org/classifiers/greengenes/gg_2022_10_backbone.v4.nb.qza)

#### Weighted Taxonomic Classifiers

- [Weighted Silva 138 99% OTUs full-length sequences](https://data.qiime2.org/2023.9/common/silva-138-99-nb-weighted-classifier.qza)
- [Weighted Greengenes 13_8 99% OTUs full-length sequences](https://data.qiime2.org/2023.9/common/gg-13-8-99-nb-weighted-classifier.qza)
- [Weighted Greengenes 13_8 99% OTUs from 515F/806R region of sequences](https://data.qiime2.org/2023.9/common/gg-13-8-99-515-806-nb-weighted-classifier.qza)

#### SEPP reference databases

- [Silva 128 SEPP reference database](https://data.qiime2.org/2023.9/common/sepp-refs-silva-128.qza)
- [Greengenes 13_8 SEPP reference database](https://data.qiime2.org/2023.9/common/sepp-refs-gg-13-8.qza)