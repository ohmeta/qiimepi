rule demultiplex:
    input:
        r1 = lambda wildcards: sample.get_run_fq(_samples, wildcards, "r1"),
        barcode = lambda wildcards: sample.get_run_fq(_samples, wildcards, "barcode_fq")
    output:
        expand(os.path.join(config["results"]["demultiplex"], "{{run}}_{{barcode}}.fq.gz"))
    params:
        prefix = os.path.join(config["results"]["demultiplex"], "{run}"),
        barcode_df = lambda wildcards: _samples.loc[wildcards.run, ["barcode_seq", "barcode_id", "fq"]].set_index("barcode_seq")
    run:
        sample.demultiplexer(input.r1, input.barcode, params.barcode_df, params.prefix)