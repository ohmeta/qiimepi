rule qiime2_feature_table_summarize:
    input:
        metadata = config["params"]["metadata"],
        qza = os.path.join(config["output"]["denoise"], "{denoiser}/table.qza")
    output:
        qzv = os.path.join(config["output"]["denoise"], "{denoiser}/table.qzv")
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_summarize.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_summarize.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime feature-table summarize \
        --i-table {input.qza} \
        --o-visualization {output.qzv} \
        --m-sample-metadata-file {input.metadata} \
        >{log} 2>&1 
        '''


rule qiime2_feature_table_tabulate:
    input:
        qza = os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs.qza")
    output:
        qzv = os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs.qzv")
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_tabulate.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_tabulate.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime feature-table tabulate-seqs \
        --i-data {input.qza} \
        --o-visualization {output.qzv} \
        >{log} 2>&1
        '''


rule qiime2_feature_table_export:
    input:
        qzv = os.path.join(config["output"]["denoise"], "{denoiser}/table.qzv")
    output:
        directory(os.path.join(config["output"]["denoise"], "{denoiser}/table_qzv"))
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_export.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.qzv} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_feature_table_tabulate_export:
    input:
        qzv = os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs.qzv")
    output:
        directory(os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs_qzv"))
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_tabulate_export.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/{denoiser}_feature_table_tabulate_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.qzv} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_feature_all:
        expand([
            os.path.join(config["output"]["denoise"], "{denoiser}/table.qzv"),
            os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs.qzv"),
            os.path.join(config["output"]["denoise"], "{denoiser}/table_qzv"),
            os.path.join(config["output"]["denoise"], "{denoiser}/rep-seqs_qzv")],
            denoiser=DENOISER)
