rule qiime2_phylotree_sepp:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza"),
    output:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree.qza"),
        placements = os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_placements.qza")
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree_sepp.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree_sepp.log")
    params:
        sepp_db = config["params"]["phylotree"]["sepp_db"]
    conda:
        config["envs"]["qiime2"]
    threads:
        config["params"]["phylotree"]["threads"]
    shell:
        '''
        qiime fragment-insertion sepp \
        --i-representative-sequences {input.rep_seq} \
        --i-reference-database {params.sepp_db} \
        --o-tree {output.tree} \
        --o-placements {output.placements} \
        --p-threads {threads} \
        >{log} 2>&1
        '''


rule qiime2_phylotree_sepp_export:
    input:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree.qza"),
        placements = os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_placements.qza")
    output:
        tree = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_qza")),
        placements = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_placements_qza"))
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree_sepp_export.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree_sepp_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.tree} \
        --output-path {output.tree} \
        >{log} 2>&1

        qiime tools export \
        --input-path {input.placements} \
        --output-path {output.placements} \
        >>{log} 2>&1
        '''


rule qiime2_phylotree_align:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza"),
    output:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/align/tree.qza"),
        tree_rooted = os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree.qza"),
        align = os.path.join(config["output"]["phylotree"], "{denoiser}/align/alignment.qza"),
        align_masked = os.path.join(config["output"]["phylotree"], "{denoiser}/align/masked_alignment.qza")
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree_align.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree_align.log")
    params:
        outdir = os.path.join(config["output"]["phylotree"], "{denoiser}/align")
    conda:
        config["envs"]["qiime2"]
    threads:
        config["params"]["phylotree"]["threads"]
    shell:
        '''
        rm -rf {params.outdir}

        qiime phylogeny align-to-tree-mafft-fasttree\
        --p-n-threads {threads} \
        --i-sequences {input.rep_seq} \
        --output-dir {params.outdir} \
        >{log} 2>&1
        '''


rule qiime2_phylotree_align_export:
    input:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/align/tree.qza"),
        tree_rooted = os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree.qza")
    output:
        tree = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/align/tree_qza")),
        tree_rooted = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree_qza"))
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree_align_export.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree_align_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input.tree} \
        --output-path {output.tree} \
        >{log} 2>&1

        qiime tools export \
        --input-path {input.tree_rooted} \
        --output-path {output.tree_rooted} \
        >>{log} 2>&1
        '''


rule qiime2_phylotree_align_visualization:
    input:
        taxonomy = os.path.join(config["output"]["taxonomic"], "{denoiser}/{classifier}/taxonomy.qza"),
        table = os.path.join(config["output"]["denoise"], "{denoiser}/table.qza"),
        tree_rooted = os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree.qza")
    output:
        qzv = os.path.join(config["output"]["phylotree"], "{denoiser}/align/{classifier}/empress_tree.qzv")
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{classifier}/{denoiser}_phylogenetic_tree_align_visualization.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{classifier}/{denoiser}_phylogenetic_tree_align_visualization.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime empress community-plot \
        --i-tree {input.tree_rooted} \
        --i-feature-table {input.table} \
        --m-feature-metadata-file {input.taxonomy} \
        --o-visualization {output.qzv} \
        >{log} 2>&1
        '''


rule qiime2_phylotree_align_visualization_export:
    input:
        os.path.join(config["output"]["phylotree"], "{denoiser}/align/{classifier}/empress_tree.qzv")
    output:
        directory(os.path.join(config["output"]["phylotree"], "{denoiser}/align/{classifier}/empress_tree_qzv"))
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{classifier}/{denoiser}_phylogenetic_tree_align_visualization_export.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{classifier}/{denoiser}_phylogenetic_tree_align_visualization_export.log")
    conda:
        config["envs"]["qiime2"]
    shell:
        '''
        qiime tools export \
        --input-path {input} \
        --output-path {output} \
        >{log} 2>&1
        '''


if config["params"]["phylotree"]["do"]:
    rule qiime2_phylotree_all:
        input:
            expand([
                os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree.qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_placements.qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/sepp/tree_placements_qza"),

                os.path.join(config["output"]["phylotree"], "{denoiser}/align/tree.qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree.qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/align/alignment.qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/align/masked_alignment.qza"),

                os.path.join(config["output"]["phylotree"], "{denoiser}/align/tree_qza"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/align/rooted_tree_qza"),

                os.path.join(config["output"]["phylotree"], "{denoiser}/align/{classifier}/empress_tree.qzv"),
                os.path.join(config["output"]["phylotree"], "{denoiser}/align/{classifier}/empress_tree_qzv")],
                denoiser=DENOISERS,
                classifier=CLASSIFIERS)
else:
        rule qiime2_phylotree_all:
            input:
