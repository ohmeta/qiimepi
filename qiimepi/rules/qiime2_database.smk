rule qiime2_database_download_silva_138_99_OTUs_full_length_sequences:
    output:
        silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_full_length_sequences"]["local"],
    params:
        silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_full_length_sequences"]["remote"]
    shell:
        '''
        wget -c -O {ouput.silva_138_99_OTUs_full_length_sequences} {params.silva_138_99_OTUs_full_length_sequences}
        '''


rule qiime2_database_download_diverse_weighted_silva_138_99_OTUs_full_length_sequences:
    output:
        diverse_weighted_silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_silva_138_99_OTUs_full_length_sequences"]["local"],
    params:
        diverse_weighted_silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_silva_138_99_OTUs_full_length_sequences"]["remote"]
    shell:
        '''
        wget -c -O {ouput.diverse_weighted_silva_138_99_OTUs_full_length_sequences} {params.diverse_weighted_silva_138_99_OTUs_full_length_sequences}
        '''


rule qiime2_database_download_human_stool_weighted_silva_138_99_OTUs_full_length_sequences:
    output:
        human_stool_weighted_silva_138_99_OTUs_full_length_sequences    = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_silva_138_99_OTUs_full_length_sequences"]["local"],
    params:
        human_stool_weighted_silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_silva_138_99_OTUs_full_length_sequences"]["remote"]
    shell:
        '''
        wget -c -O {ouput.human_stool_weighted_silva_138_99_OTUs_full_length_sequences} {params.human_stool_weighted_silva_138_99_OTUs_full_length_sequences}
        '''


rule qiime2_database_download_gtdb_classifier_r220:
    output:
        gtdb_classifier_r220  = config["params"]["database"]["taxonomy_classifiers"]["gtdb_classifier_r220"]["local"],
    params:
        gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["gtdb_classifier_r220"]["remote"]
    shell:
        '''
        wget -c -O {ouput.gtdb_classifier_r220} {params.gtdb_classifier_r220}
        '''


rule qiime2_database_download_diverse_weighted_gtdb_classifier_r220:
    output:
        diverse_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_gtdb_classifier_r220"]["local"],
    params:
        diverse_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_gtdb_classifier_r220"]["remote"]
    shell:
        '''
        wget -c -O {ouput.diverse_weighted_gtdb_classifier_r220} {params.diverse_weighted_gtdb_classifier_r220}
        '''


rule qiime2_database_download_human_stool_weighted_gtdb_classifier_r220:
    output:
        human_stool_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_gtdb_classifier_r220"]["local"],
    params:
        human_stool_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_gtdb_classifier_r220"]["remote"]
    shell:
        '''
        wget -c -O {ouput.human_stool_weighted_gtdb_classifier_r220} {params.human_stool_weighted_gtdb_classifier_r220}
        '''


rule qiime2_database_download_greengenes2_2024_09_full_length_sequences:
    output:
        greengenes2_2024_09_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_full_length_sequences"]["local"],
    params:
        greengenes2_2024_09_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_full_length_sequences"]["remote"]
    shell:
        '''
        wget -c -O {ouput.greengenes2_2024_09_full_length_sequences} {params.greengenes2_2024_09_full_length_sequences}
        '''


rule qiime2_database_download_greengenes2_2024_09_from_515F_806R_region_of_sequences:
    output:
        greengenes2_2024_09_from_515F_806R_region_of_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_from_515F_806R_region_of_sequences"]["local"],
    params:
        greengenes2_2024_09_from_515F_806R_region_of_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_from_515F_806R_region_of_sequences"]["remote"]
    shell:
        '''
        wget -c -O {ouput.greengenes2_2024_09_from_515F_806R_region_of_sequences} {params.greengenes2_2024_09_from_515F_806R_region_of_sequences}
        '''


rule qiime2_database_done:
    input:
        silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_full_length_sequences"]["local"],
        diverse_weighted_silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_silva_138_99_OTUs_full_length_sequences"]["local"],
        human_stool_weighted_silva_138_99_OTUs_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_silva_138_99_OTUs_full_length_sequences"]["local"],
        gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["gtdb_classifier_r220"]["local"],
        diverse_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["diverse_weighted_gtdb_classifier_r220"]["local"],
        human_stool_weighted_gtdb_classifier_r220 = config["params"]["database"]["taxonomy_classifiers"]["human_stool_weighted_gtdb_classifier_r220"]["local"],
        greengenes2_2024_09_full_length_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_full_length_sequences"]["local"],
        greengenes2_2024_09_from_515F_806R_region_of_sequences = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2024_09_from_515F_806R_region_of_sequences"]["local"]
    output:
        os.path.join(config["output"]["database"], "done")
    shell:
        '''
        touch {output}
        '''


rule qiime2_database_all:
    input:
        os.path.join(config["output"]["database"], "done")