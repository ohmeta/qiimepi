rule qiime2_phylotree:
    input:
        rep_seq = os.path.join(config["output"]["denoise"], "{denoiser}/rep_seqs.qza"),
    output:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/tree.qza"),
        placements = os.path.join(config["output"]["phylotree"], "{denoiser}/tree_placements.qza")
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree.log")
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


rule qiime2_phylotree_export:
    input:
        tree = os.path.join(config["output"]["phylotree"], "{denoiser}/tree.qza"),
        placements = os.path.join(config["output"]["phylotree"], "{denoiser}/tree_placements.qza")
    output:
        tree = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/tree_qza")),
        placements = directory(os.path.join(config["output"]["phylotree"], "{denoiser}/tree_placements_qza"))
    benchmark:
        os.path.join(config["output"]["phylotree"], "benchmark/{denoiser}_phylogenetic_tree_export.benchmark.txt")
    log:
        os.path.join(config["output"]["phylotree"], "logs/{denoiser}_phylogenetic_tree_export.log")
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


rule qiime2_phylotree_all:
    input:
        expand([
            os.path.join(config["output"]["phylotree"], "{denoiser}/tree.qza"),
            os.path.join(config["output"]["phylotree"], "{denoiser}/tree_placements.qza"),
            os.path.join(config["output"]["phylotree"], "{denoiser}/tree_qza"),
            os.path.join(config["output"]["phylotree"], "{denoiser}/tree_placements_qza")],
            denoiser=DENOISER)
