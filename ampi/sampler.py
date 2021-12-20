#!/usr/bin/env python3

import pandas as pd


def get_reads(sample_df, wildcards, col):
    return sample_df.loc[[wildcards.sample], col].dropna().tolist()
