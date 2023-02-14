if reads_layout == "PE":
    rule qiime2_denoise_dada2:
        input:
            os.path.join(config["output"]["import"], "demux.qza")
        output:
            rep_seq = os.path.join(config["output"]["denoise"], "dada2/rep_seqs.qza"),
            table = os.path.join(config["output"]["denoise"], "dada2/table.qza"),
            stats = os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qza")
        benchmark:
            os.path.join(config["output"]["denoise"], "logs/denoise_dada2.benchmark.txt")
        log:
            os.path.join(config["output"]["denoise"], "logs/denoise_dada2.log")
        params:
            trunc_len_f = config["params"]["denoise"]["dada2"]["paired"]["trunc_len_f"],
            trunc_len_r = config["params"]["denoise"]["dada2"]["paired"]["trunc_len_r"],
            trim_left_f = config["params"]["denoise"]["dada2"]["paired"]["trim_left_f"],
            trim_left_r = config["params"]["denoise"]["dada2"]["paired"]["trim_left_r"]
        threads:
            config["params"]["denoise"]["threads"]
        conda:
            config["envs"]["qiime2"]
        shell:
            '''
            qiime dada2 denoise-paired \
            --i-demultiplexed-seqs {input} \
            --p-trunc-len-f {params.trunc_len_f} \
            --p-trunc-len-r {params.trunc_len_r} \
            --p-trim-left-f {params.trim_left_f} \
            --p-trim-left-r {params.trim_left_r} \
            --o-representative-sequences {output.rep_seq} \
            --o-table {output.table} \
            --o-denoising-stats {output.stats} \
            --verbose \
            --p-n-threads {threads} \
            >{log} 2>&1
            '''

else:

    rule qiime2_denoise_dada2:
        input:
            os.path.join(config["output"]["import"], "demux.qza")
        output:
            rep_seq = os.path.join(config["output"]["denoise"], "dada2/rep_seqs.qza"),
            table = os.path.join(config["output"]["denoise"], "dada2/table.qza"),
            stats = os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qza")
        benchmark:
            os.path.join(config["output"]["denoise"], "logs/denoise_dada2.benchmark.txt")
        log:
            os.path.join(config["output"]["denoise"], "logs/denoise_dada2.log")
        params:
            trunc_len = config["params"]["denoise"]["dada2"]["single"]["trunc_len"],
            trim_left = config["params"]["denoise"]["dada2"]["single"]["trim_left"]
        threads:
            config["params"]["denoise"]["threads"]
        conda:
            config["envs"]["qiime2"]
        shell:
            '''
            qiime dada2 denoise-single\
            --i-demultiplexed-seqs {input} \
            --p-trunc-len {params.trunc_len} \
            --p-trim-left {params.trim_left} \
            --o-representative-sequences {output.rep_seq} \
            --o-table {output.table} \
            --o-denoising-stats {output.stats} \
            --verbose \
            --p-n-threads {threads} \
            >{log} 2>&1
            '''


rule qiime2_denoise_dada2_visualization:
    input:
        stats = os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qza")
    output:
        stats = os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qzv")
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/denoise_dada2_visualization.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/denoise_dada2_visualization.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime metadata tabulate \
        --m-input-file {input.stats} \
        --o-visualization {output.stats} \
        >{log} 2>&1
        '''


rule qiime2_denoise_dada2_export:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "dada2/rep_seqs.qza"),
        table = os.path.join(config["output"]["denoise"], "dada2/table.qza"),
        stats = os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qza")
    output:
        rep_seq = directory(os.path.join(config["output"]["denoise"], "dada2/rep_seqs_qza")),
        table = directory(os.path.join(config["output"]["denoise"], "dada2/table_qza")),
        stats = directory(os.path.join(config["output"]["denoise"], "dada2/denoise_stats_qza"))
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/denoise_dada2_export.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/denoise_dada2_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.stats} \
        --output-path {output.stats} >{log} 2>&1

        qiime tools export \
        --input-path {input.rep_seq} \
        --output-path {output.rep_seq}

        qiime tools export \
        --input-path {input.table} \
        --output-path {output.table} >>{log} 2>&1

        biom convert \
        -i {output.table}/feature-table.biom \
        -o {output.table}/feature-table.tsv \
        --to-tsv >>{log} 2>&1
        '''


rule qiime2_denoise_deblur:
    input:
        os.path.join(config["output"]["import"], "demux.qza")
    output:
        demux = os.path.join(config["output"]["denoise"], "deblur/demux_filtered.qza"),
        demux_stats = os.path.join(config["output"]["denoise"], "deblur/demux_filtered_stats.qza"),
        rep_seq = os.path.join(config["output"]["denoise"], "deblur/rep_seqs.qza"),
        table = os.path.join(config["output"]["denoise"], "deblur/table.qza"),
        stats = os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qza")
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur.log")
    params:
        trim_len = config["params"]["denoise"]["deblur"]["trim_len"],
        left_trim_len = config["params"]["denoise"]["deblur"]["left_trim_len"]
    threads:
        config["params"]["denoise"]["threads"]
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        echo "Running qiime quality-filter q-score" >{log} 2>&1

        qiime quality-filter q-score \
        --i-demux {input} \
        --o-filtered-sequences {output.demux} \
        --o-filter-stats {output.demux_stats} \
        >>{log} 2>&1

        echo "Running qiime deblur denoise-16S" >>{log} 2>&1

        qiime deblur denoise-16S \
        --i-demultiplexed-seqs {output.demux} \
        --p-trim-length {params.trim_len} \
        --p-left-trim-len {params.left_trim_len} \
        --p-sample-stats \
        --o-representative-sequences {output.rep_seq} \
        --o-table {output.table} \
        --o-stats {output.stats} \
        >>{log} 2>& 1
        '''


rule qiime2_denoise_deblur_visualization:
    input:
        demux_stats = os.path.join(config["output"]["denoise"], "deblur/demux_filtered_stats.qza"),
        stats = os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qza")
    output:
        demux_stats = os.path.join(config["output"]["denoise"], "deblur/demux_filtered_stats.qzv"),
        stats = os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qzv")
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur_visualization.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur_visualization.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime metadata tabulate \
        --m-input-file {input.demux_stats} \
        --o-visualization {output.demux_stats} \
        >{log} 2>&1

        qiime deblur visualize-stats \
        --i-deblur-stats {input.stats} \
        --o-visualization {output.stats} \
        >>{log} 2>&1
        '''


rule qiime2_denoise_deblur_export:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "deblur/rep_seqs.qza"),
        table = os.path.join(config["output"]["denoise"], "deblur/table.qza"),
        stats = os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qza")
    output:
        rep_seq = directory(os.path.join(config["output"]["denoise"], "deblur/rep_seqs_qza")),
        table = directory(os.path.join(config["output"]["denoise"], "deblur/table_qza")),
        stats = directory(os.path.join(config["output"]["denoise"], "deblur/denoise_stats_qza"))
    benchmark:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur_export.benchmark.txt")
    log:
        os.path.join(config["output"]["denoise"], "logs/denoise_deblur_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.stats} \
        --output-path {output.stats} \
        >{log} 2>&1

        qiime tools export \
        --input-path {input.rep_seq} \
        --output-path {output.rep_seq} \
        >>{log} 2>&1

        qiime tools export \
        --input-path {input.table} \
        --output-path {output.table} \
        >>{log} 2>&1
        '''


def gen_denoise_output():
    output = []

    dada2_output = [
        os.path.join(config["output"]["denoise"], "dada2/rep_seqs.qza"),
        os.path.join(config["output"]["denoise"], "dada2/rep_seqs_qza"),
        os.path.join(config["output"]["denoise"], "dada2/table.qza"),
        os.path.join(config["output"]["denoise"], "dada2/table_qza"),
        os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qza"),
        os.path.join(config["output"]["denoise"], "dada2/denoise_stats_qza"),
        os.path.join(config["output"]["denoise"], "dada2/denoise_stats.qzv")
    ]

    deblur_output = [
        os.path.join(config["output"]["denoise"], "deblur/demux_filtered.qza"),
        os.path.join(config["output"]["denoise"], "deblur/demux_filtered_stats.qza"),
        os.path.join(config["output"]["denoise"], "deblur/demux_filtered_stats.qzv"),
        os.path.join(config["output"]["denoise"], "deblur/rep_seqs.qza"),
        os.path.join(config["output"]["denoise"], "deblur/rep_seqs_qza"),
        os.path.join(config["output"]["denoise"], "deblur/table.qza"),
        os.path.join(config["output"]["denoise"], "deblur/table_qza"),
        os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qza"),
        os.path.join(config["output"]["denoise"], "deblur/denoise_stats_qza"),
        os.path.join(config["output"]["denoise"], "deblur/denoise_stats.qzv")
    ]

    if config["params"]["denoise"]["dada2"]["do"]:
        output += dada2_output

    if config["params"]["denoise"]["deblur"]["do"]:
        output += deblur_output

    return output


rule qiime2_denoise_all:
    input:
        gen_denoise_output()
