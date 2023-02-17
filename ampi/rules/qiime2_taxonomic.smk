rule qiime2_taxonomic_classification:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_{denoiser}.log")
    params:
        classifier = config["params"]["taxonomic"]["classifier"]
    threads:
        config["params"]["taxonomic"]["threads"]
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        export TMPDIR={TMPDIR}

        qiime feature-classifier classify-sklearn \
        --i-classifier {params.classifier} \
        --i-reads {input.rep_seq} \
        --o-classification {output} \
        --p-n-jobs {threads} \
        --verbose > {log} 2>&1
        '''


rule qiime2_taxonomic_classification_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_qza"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_classification_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_classification_export_{denoiser}.log")
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
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_visualization_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_visualization_{denoiser}.log")
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
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_visualization_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_visualization_export_{denoiser}.log")
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
        metadata = config["params"]["metadata"],
        table = os.path.join(config["output"]["denoise"], "{denoiser}/table.qza"),
        taxonomy = os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_barplot.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_barplot_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_barplot_{denoiser}.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime taxa barplot \
        --i-table {input.table} \
        --i-taxonomy {input.taxonomy} \
        --m-metadata-file {input.metadata} \
        --o-visualization {output} \
        >{log} 2>&1
        '''


rule qiime2_taxonomic_barplot_export:
    input:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_barplot.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_barplot_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_barplot_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_barplot_export_{denoiser}.log")
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
        taxonomy = os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    output:
        qzv = os.path.join(config["output"]["taxonomic"], "{denoiser}/krona.qzv")
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_krona_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_krona_{denoiser}.log")
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
        os.path.join(config["output"]["taxonomic"], "{denoiser}/krona.qzv")
    output:
        directory(os.path.join(config["output"]["taxonomic"], "{denoiser}/krona_qzv"))
    benchmark:
        os.path.join(config["output"]["taxonomic"], "benchmark/taxonomic_krona_export_{denoiser}.benchmark.txt")
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_krona_export_{denoiser}.log")
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
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_qza"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_barplot.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy_barplot_qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/krona.qzv"),
            os.path.join(config["output"]["taxonomic"], "{denoiser}/krona_qzv")],
            denoiser=DENOISER)
