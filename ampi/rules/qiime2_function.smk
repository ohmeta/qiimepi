# PICRUSt2 pipeline

## Place reads into reference tree
## Hidden-state prediction of gene families
## Generate metagenome predictions
## Pathway-level inference
## Add functional descriptions


rule qiime2_function_picrust2:
    input:
        rep_seq_dir = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs_qza"),
        table_dir = os.path.join(config["output"]["denoise"], "{denoiser}/table_qza")
    output:
        os.path.join(config["output"]["function"], "{denoiser}/picrust2/done")
    benchmark:
        os.path.join(config["output"]["function"], "benchmark/{denoiser}_picrust2.benchmark.txt")
    log:
        os.path.join(config["output"]["function"], "logs/{denoiser}_picrust2.log")
    conda:
        config["envs"]["picrust2"]
    threads:
        config["params"]["function"]["threads"]
    shell:
        '''
        outdir=$(dirname {output})

        rm -rf $outdir

        picrust2_pipeline.py \
        -p {threads} \
        --stratified \
        --study_fasta {input.rep_seq_dir}/dna-sequences.fasta \
        --input {input.table_dir}/feature-table.biom \
        --output $outdir \
        >{log} 2>&1

        touch {output}
        '''


rule qiime2_function_picrust2_add_descriptions:
    input:
        os.path.join(config["output"]["function"], "{denoiser}/picrust2/done")
    output:
        os.path.join(config["output"]["function"], "{denoiser}/picrust2/done_description")
    benchmark:
        os.path.join(config["output"]["function"], "benchmark/{denoiser}_picrust2_add_description.benchmark.txt")
    log:
        os.path.join(config["output"]["function"], "logs/{denoiser}_picrust2_add_description.log")
    conda:
        config["envs"]["picrust2"]
    shell:
        '''
        outdir=$(dirname {input})

        add_descriptions.py \
        -i $outdir/EC_metagenome_out/pred_metagenome_unstrat.tsv.gz \
        -m EC \
        -o $outdir/EC_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz \
        >{log} 2>&1

        add_descriptions.py \
        -i $outdir/KO_metagenome_out/pred_metagenome_unstrat.tsv.gz \
        -m KO \
        -o $outdir/KO_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz \
        >>{log} 2>&1

        add_descriptions.py \
        -i $outdir/pathways_out/path_abun_unstrat.tsv.gz \
        -m METACYC \
        -o $outdir/pathways_out/path_abun_unstrat_descrip.tsv.gz \
        >>{log} 2>&1

        touch {output}
        '''


rule qiime2_function_all:
    input:
        expand([
            os.path.join(config["output"]["function"], "{denoiser}/picrust2/done"),
            os.path.join(config["output"]["function"], "{denoiser}/picrust2/done_description")],
            denoiser=DENOISER)
