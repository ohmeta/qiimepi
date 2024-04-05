rule qiime2_database_download:
    output:
        silva_138_99_nb_classifier = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_full_length_sequences"],
        silva_138_99_515_806_nb_classifier = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_from_515F_806R_region_of_sequences"],
        gg_2022_10_backbone_full_length_nb = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2022.10_full_length_sequences"],
        gg_2022_10_backbone_v4_nb = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2022.10_from_515F_806R_region_of_sequences"],
        silva_138_99_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_silva_138_99_OTUs_full_length_sequences"],
        gg_13_8_99_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_greengenes_13_8_99_OTUs_full_length_sequences"],
        gg_13_8_99_515_806_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_greengenes_13_8_99_OTUs_from_515F_806R_region_of_sequences"]
    shell:
        '''
        wget -c -O {output.silva_138_99_nb_classifier} -c https://data.qiime2.org/2024.2/common/silva-138-99-nb-classifier.qza
        wget -c -O {output.silva_138_99_515_806_nb_classifier} https://data.qiime2.org/2024.2/common/silva-138-99-515-806-nb-classifier.qza
        wget -c -O {output.gg_2022_10_backbone_full_length_nb} https://data.qiime2.org/classifiers/greengenes/gg_2022_10_backbone_full_length.nb.qza
        wget -c -O {output.gg_2022_10_backbone_v4_nb} https://data.qiime2.org/classifiers/greengenes/gg_2022_10_backbone.v4.nb.qza

        wget -c -O {output.silva_138_99_nb_weighted_classifier} https://data.qiime2.org/2024.2/common/silva-138-99-nb-weighted-classifier.qza
        wget -c -O {output.gg_13_8_99_nb_weighted_classifier} https://data.qiime2.org/2024.2/common/gg-13-8-99-nb-weighted-classifier.qza
        wget -c -O {output.gg_13_8_99_515_806_nb_weighted_classifier} https://data.qiime2.org/2024.2/common/gg-13-8-99-515-806-nb-weighted-classifier.qza
        '''


rule qiime2_database_done:
    input:
        silva_138_99_nb_classifier = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_full_length_sequences"],
        silva_138_99_515_806_nb_classifier = config["params"]["database"]["taxonomy_classifiers"]["silva_138_99_OTUs_from_515F_806R_region_of_sequences"],
        gg_2022_10_backbone_full_length_nb = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2022.10_full_length_sequences"],
        gg_2022_10_backbone_v4_nb = config["params"]["database"]["taxonomy_classifiers"]["greengenes2_2022.10_from_515F_806R_region_of_sequences"],
        silva_138_99_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_silva_138_99_OTUs_full_length_sequences"],
        gg_13_8_99_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_greengenes_13_8_99_OTUs_full_length_sequences"],
        gg_13_8_99_515_806_nb_weighted_classifier = config["params"]["database"]["taxonomy_classifiers"]["weighted_greengenes_13_8_99_OTUs_from_515F_806R_region_of_sequences"]
    output:
        os.path.join(config["output"]["database"], "done")
    shell:
        '''
        touch {output}
        '''


rule qiime2_database_all:
    input:
        os.path.join(config["output"]["database"], "done")