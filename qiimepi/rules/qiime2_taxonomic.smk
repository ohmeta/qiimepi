def get_taxonomic_classifier(wildcards):
    return config["params"]["database"]["taxonomy_classifiers"][wildcards.classifier]


rule qiime2_taxonomic_classification:
    input:
        db_done = os.path.join(config["output"]["database"], "done"),
        classifier = lambda wildcards: get_taxonomic_classifier(wildcards),
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_{denoiser}.log")
    threads:
        config["params"]["taxonomic"]["threads"]
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        export TMPDIR={TMPDIR}

        qiime feature-classifier classify-sklearn \
        --i-classifier {input.classifier} \
        --i-reads {input.rep_seq} \
        --o-classification {output} \
        --p-n-jobs {threads} \
        --verbose > {log} 2>&1
        '''


rule qiime2_taxonomic_classification_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_qza"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_classification_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_classification_export_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_visualization:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_visualization_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_visualization_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime metadata tabulate \
        --m-input-file {input} \
        --o-visualization {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_visualization_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_visualization_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_visualization_export_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_barplot:
    input:
        table = os.path.join(config["output"]["denoise"], "{denoiser}/table.qza"),
        taxonomy = os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_barplot.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_barplot_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_barplot_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime taxa barplot \
        --i-table {input.table} \
        --i-taxonomy {input.taxonomy} \
        --o-visualization {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_barplot_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_barplot.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_barplot_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_barplot_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_barplot_export_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_krona:
    input:
        table = os.path.join(config["output"]["denoise"], "dada2/table.qza"),
        taxonomy = os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza")
    output:
        qzv = os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/krona.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_krona_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_krona_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime krona collapse-and-plot \
        --i-table {input.table} \
        --i-taxonomy {input.taxonomy} \
        --o-krona-plot {output.qzv} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_krona_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/krona.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/krona_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/{classifier}/taxonomic_krona_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/{classifier}/taxonomic_krona_export_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input} \
        --output-path {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_all:
    input:
        expand([
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_qza"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_barplot.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy_barplot_qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/krona.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/krona_qzv")],
            denoiser=DENOISERS,
            classifier=CLASSIFIERS)
