#!/usr/bin/env snakemake

import sys
import os
import ampi
import pandas as pd

shell.executable("bash")

AMPI_DIR = ampi.__path__[0]


reads_layout = "PE"
if "Paired" in config["params"]["import"]["type"]:
    reads_layout = "PE"
else:
    reads_layout = "SE"

SAMPLES = ampi.parse_samples(config["params"]["samples"], reads_layout, TRUE)

#READS_FORMAT = "sra" \
#    if "sra" in SAMPLES.columns \
#       else "fastq"

TMPDIR = os.path.realpath(config["output"]["tmp"])
os.environ["TMPDIR"] = TMPDIR
os.makedirs(config["output"]["tmp"], exist_ok=True)


DENOISER = []

if config["params"]["denoise"]["dada2"]["do"]:
    DENOISER.append("dada2")

if config["params"]["denoise"]["deblur"]["do"]:
    DENOISER.append("deblur")


include: "../rules/qiime2_import.smk"
include: "../rules/qiime2_denoise.smk"
include: "../rules/qiime2_feature.smk"
include: "../rules/qiime2_taxonomic.smk"


rule all:
    input:
        rules.qiime2_import_all.input,
        rules.qiime2_denoise_all.input,
        rules.qiime2_taxonomic_all.input
