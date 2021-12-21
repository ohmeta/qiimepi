def raw_short_reads(wildcards):
    if READS_FORMAT == "fastq":
        if IS_PE:
            return [ampi.get_reads(SAMPLES, wildcards, "fq1"),
                    ampi.get_reads(SAMPLES, wildcards, "fq2")]
        else:
            return [ampi.get_reads(SAMPLES, wildcards, "fq1")]

    elif READS_FORMAT == "sra":
        return [ampi.get_reads(SAMPLES, wildcards, "sra")]


rule qiime2_import:
    input:
        config["params"]["samples"]
    output:
        qza = os.path.join(config["output"]["import"], "demux.qza"),
        qzv = os.path.join(config["output"]["import"], "demux.qzv")
    params:
        type = config["params"]["type"],
        format = config["params"]["format"]
    log:
        os.path.join(config["output"]["import"], "logs/qiime_import.log")
    shell:
        '''
        qiime tools import \
        --type '{params.type}' \
        --input-format {params.format} \
        --input-path {input} \
        --output-path {output.qza} > {log} 2>&1

        qiime demux summarize \
        --i-data {output.qza} \
        --o-visualization {output.qzv} >> {log} 2>&1
        '''
