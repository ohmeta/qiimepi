#!/usr/bin/env snakemake

import sys
import ampi
import pandas as pd

shell.executable("bash")

AMPI_DIR = ampi.__path__[0]

SAMPLES = ampi.parse_samples(config["params"]["samples"])


READS_FORMAT = "sra" \
    if "sra" in SAMPLES.columns \
       else "fastq"


include: "../rules/qiime2_import.smk"
include: "../rules/qiime2_denoise.smk"
include: "../rules/qiime2_feature.smk"
include: "../rules/qiime2_taxonomic.smk"


rule:
    input:
        os.path.join(config["output"]["import"], "demux.qza"),
        os.path.join(config["output"]["import"], "demux.qzv")
