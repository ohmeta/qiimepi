demultiplex_output = expand(
    "{demultiplex}/{run}_{barcode}.fq.gz".split(),
    zip,
    demultiplex=config["results"]["demultiplex"],
    run=_samples.run,
    barcode=_samples.barcode_id
)

all = demultiplex_output