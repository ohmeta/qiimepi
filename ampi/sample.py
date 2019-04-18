#!/usr/bin/env python

import argparse
import os
import gzip
from Bio import SeqIO
import pandas as pd


def split(reads_file, barcode_file, samples_file, prefix):
    if reads_file.endswith(".gz"):
        reads_h = gzip.open(reads_file, 'rt')
    else:
        reads_h = open(reads_file, 'r')
    if barcode_file.endswith(".gz"):
        barcode_h = gzip.open(barcode_file, 'rt')
    else:
        barcode_h = open(barcode_file, 'r')
    sample_barcode = pd.read_csv(samples_file, sep='\t').set_index('barcode', drop=False)
    sample_barcode = sample_barcode.assign(filename=sample_barcode.barcode_num.apply(
        lambda x: prefix + "_" + str(x) + ".fq.gz"))

    reads_partition = {}
    out_partition = {}
    for barcode_seq in sample_barcode.index:
        reads_partition[barcode_seq] = []
        out_partition[barcode_seq] = gzip.open(sample_barcode.loc[barcode_seq, "filename"], 'wb')
    count = 0

    for read, barcode in zip(SeqIO.parse(reads_h, 'fastq'), SeqIO.parse(barcode_h, 'fastq')):
        if barcode.seq in reads_partition:
            count += 1
            reads_partition[barcode.seq].append(read)
            if count == 100000:
                for barcode_seq in reads_partition:
                    if len(reads_partition[barcode_seq]) > 0:
                        SeqIO.write(reads_partition[barcode_seq], out_partition[barcode_seq], 'fastq')
                        reads_partition[barcode_seq] = []
                count = 0

    for barcode_seq in reads_partition:
        if len(reads_partition[barcode_seq]) > 0:
            SeqIO.write(reads_partition[barcode_seq], out_partition[barcode_seq], 'fastq')
            reads_partition[barcode_seq] = []
            out_partition[barcode_seq].close()


def main():
    parser = argparse.ArgumentParser("split fastq file by sample barcode")
    parser.add_argument('-r', '--reads', type=str, help='fastq file')
    parser.add_argument('-b', '--barcode', type=str, help='barcode file')
    parser.add_argument('-s', '--samples', type=str, help='samples and barcode information')
    parser.add_argument('-p', '--prefix', type=str, help='output prefix')

    args = parser.parse_args()
    outdir = os.path.basename(args.prefix)
    os.makedirs(outdir, exist_ok=True)