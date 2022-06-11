#!/usr/bin/env python3

import os
import sys
import pandas as pd


def parse_samples(samples_tsv, reads_layout="PE", check_samples=False):
    samples_df = pd.read_csv(samples_tsv, sep="\t")\
                   .set_index("sample-id", drop=False)

    cancel = False

    file_header = ""
    if reads_layout == "PE":
        file_header = "forward-absolute-filepath"
    else:
        file_header = "absolute-filepath"

    if file_header in samples_df.columns:
        for sample_id in samples_df.index.unique():
            if "." in sample_id:
                print(f"{sample_id} contain '.', please remove '.', now quiting :)")
                cancel = True

            fq1_list = samples_df.loc[[sample_id], file_header].dropna().tolist()
            if reads_layout == "PE":
                fq2_list = samples_df.loc[[sample_id], file_header.replace("forward", "reverse")].dropna().tolist()

            for fq_file in fq1_list:
                if not fq_file.endswith(".gz"):
                    print(f"{fq_file} need gzip format")
                    cancel = True
                if check_samples:
                    if not os.path.exists(fq_file):
                        print(f"{fq_file} not exists")
                        cancel = True

            if reads_layout == "PE":
                for fq_file in fq2_list:
                    if not fq_file.endswith(".gz"):
                        print(f"{fq_file} need gzip format")
                        cancel = True
                    if check_samples:
                        if not os.path.exists(fq_file):
                            print(f"{fq_file} not exists")
                            cancel = True

    else:
        print("wrong header: {header}".format(header=samples_df.columns))
        cancel = True

    if cancel:
        sys.exit(-1)
    else:
        return samples_df


def get_reads(sample_df, wildcards, col):
    return sample_df.loc[[wildcards.sample], col].dropna().tolist()
