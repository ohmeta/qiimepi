#!/usr/bin/env snakemake

import sys
import metapi
import pandas as pd

shell.executable("bash")

AMPI_DIR = amppi.__path__[0]

SAMPLES = ampi.parse_samples(config["params"]["samples"])

include: "../rules/qiime2_import.smk"
include: "../rules/qiime2_denoise.smk"
include: "../rules/qiime2_feature.smk"
include: "../rules/qiime2_taxonomic.smk"

rule:
    input:
