#!/bin/bash
#$ -N gem_generate_index_homo_sapiens_hg38
#$ -q short-sl65
#$ -l virtual_free=50G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/gem_generate_index_homo_sapiens_hg38_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/gem_generate_index_homo_sapiens_hg38_$JOB_ID.err
#$ -pe smp 8
/software/mb/bin/gem-indexer -i /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/ucsc/hg38.fa -o /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/ucsc/hg38.gem -T 8
