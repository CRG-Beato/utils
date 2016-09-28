#!/bin/bash
#$ -N gem_generate_index_drosophila_melanogaster_dm6
#$ -q short-sl65
#$ -l virtual_free=50G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/gem_generate_index_drosophila_melanogaster_dm6_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/gem_generate_index_drosophila_melanogaster_dm6_$JOB_ID.err
#$ -pe smp 8
/software/mb/bin/gem-indexer -i /users/GR/mb/jquilez/assemblies/drosophila_melanogaster/dm6/ucsc/dm6_chr2-4XYM.fa -o /users/GR/mb/jquilez/assemblies/drosophila_melanogaster/dm6/ucsc/dm6_chr2-4XYM -T 8
