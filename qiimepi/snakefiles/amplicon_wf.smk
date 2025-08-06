#!/usr/bin/env snakemake

import sys
import os

import pandas as pd

import qiimepi

shell.executable("bash")

QIIMEPI_DIR = qiimepi.__path__[0]


reads_layout = "PE"
if "Paired" in config["params"]["import"]["type"]:
    reads_layout = "PE"
else:
    reads_layout = "SE"

SAMPLES = qiimepi.parse_samples(config["params"]["samples"], reads_layout, True)

#READS_FORMAT = "sra" \
#    if "sra" in SAMPLES.columns \
#       else "fastq"

TMPDIR = os.path.realpath(config["output"]["tmp"])
os.environ["TMPDIR"] = TMPDIR
os.makedirs(config["output"]["tmp"], exist_ok=True)


DENOISERS = []

if config["params"]["denoise"]["dada2"]["do"]:
    DENOISERS.append("dada2")

if config["params"]["denoise"]["deblur"]["do"]:
    DENOISERS.append("deblur")


CLASSIFIERS = config["params"]["taxonomic"]["classifiers"]


include: "../rules/qiime2_database.smk"
include: "../rules/qiime2_import.smk"
include: "../rules/qiime2_denoise.smk"
include: "../rules/qiime2_feature.smk"
include: "../rules/qiime2_taxonomic.smk"
include: "../rules/qiime2_phylotree.smk"
include: "../rules/qiime2_function.smk"


rule all:
    input:
        rules.qiime2_database_all.input,
        rules.qiime2_import_all.input,
        rules.qiime2_denoise_all.input,
        rules.qiime2_feature_all.input,
        rules.qiime2_taxonomic_all.input,
        rules.qiime2_phylotree_all.input,
        rules.qiime2_function_all.input


localrules:
    qiime2_database_download_silva_138_99_OTUs_full_length_sequences,
    qiime2_database_download_diverse_weighted_silva_138_99_OTUs_full_length_sequences,
    qiime2_database_download_human_stool_weighted_silva_138_99_OTUs_full_length_sequences,
    qiime2_database_download_gtdb_classifier_r220,
    qiime2_database_download_diverse_weighted_gtdb_classifier_r220,
    qiime2_database_download_human_stool_weighted_gtdb_classifier_r220,
    qiime2_database_download_greengenes2_2024_09_full_length_sequences,
    qiime2_database_download_greengenes2_2024_09_from_515F_806R_region_of_sequences,
    qiime2_database_done,
    qiime2_database_all,
    qiime2_import_all,
    qiime2_denoise_all,
    qiime2_feature_all,
    qiime2_taxonomic_all,
    qiime2_phylotree_all,
    qiime2_function_all
