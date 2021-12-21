#!/usr/bin/env python3

import pandas as pd


def parse_samples(samples_tsv, reads_layout="pe", check_samples=False):
    samples_df = pd.read_csv(samples_tsv, sep="\t")\
                   .set_index("sample-id", drop=False)

    cancel = False
    if "forward-absolute-filepath" in samples_df.columns:
        for sample_id in samples_df.index.unique():
            if "." in sample_id:
                print(f"{sample_id} contain '.', please remove '.', now quiting :)")
                cancel = True

            fq1_list = samples_df.loc[[sample_id], "forward-absolute-filepath"].dropna().tolist()
            fq2_list = samples_df.loc[[sample_id], "reverse-absolute-filepath"].dropna().tolist()
            for fq_file in fq1_list:
                if not fq_file.endswith(".gz"):
                    print(f"{fq_file} need gzip format")
                    cancel = True
                if check_samples:
                    if not os.path.exists(fq_file):
                        print(f"{fq_file} not exists")
                        cancel = True
                    if reads_layout == "pe":
                        if len(fq2_list) == 0:
                            print(f"{sample_id} fq2 not exists")
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
