rule qiime2_import:
    input:
        config["params"]["samples"]
    output:
        qza = os.path.join(config["output"]["import"], "demux.qza")
    params:
        type = config["params"]["import"]["type"],
        format = config["params"]["import"]["format"]
    log:
        os.path.join(config["output"]["import"], "logs/qiime_import.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools import \
        --type '{params.type}' \
        --input-format {params.format} \
        --input-path {input} \
        --output-path {output.qza} > {log} 2>&1
        '''


rule qiime2_import_summarize:
    input:
        qza = os.path.join(config["output"]["import"], "demux.qza")
    output:
        qzv = os.path.join(config["output"]["import"], "demux.qzv")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        export TMPDIR={TMPDIR}

        qiime demux summarize \
        --i-data {input.qza} \
        --o-visualization {output.qzv}
        '''


rule qiime2_import_summarize_export:
    input:
        qzv = os.path.join(config["output"]["import"], "demux.qzv")
    output:
        qzv_out = directory(os.path.join(config["output"]["import"], "demux_qzv"))
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.qzv} \
        --output-path {output.qzv_out}
        '''


rule qiime2_import_all:
    input:
        os.path.join(config["output"]["import"], "demux.qza"),
        os.path.join(config["output"]["import"], "demux.qzv"),
        os.path.join(config["output"]["import"], "demux_qzv")
