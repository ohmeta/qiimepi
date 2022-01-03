rule qiime2_taxonomic:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza")
    output:
        os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza")
    params:
        classifier = config["params"]["taxonomic"]["classifier"]
    log:
        os.path.join(config["output"]["taxonomic"], "logs/taxonomic_{denoiser}.log")
    threads:
        config["params"]["taxonomic"]["threads"]
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


rule qiime2_taxonomic_all:
    input:
        expand(os.path.join(config["output"]["taxonomic"], "{denoiser}/taxonomy.qza"),
               denoiser=DENOISER)
