#!/bin/bash
#$ -N gem_generate_index_mus_musculus_mm10
#$ -q short-sl65
#$ -l virtual_free=50G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/gem_generate_index_mus_musculus_mm10_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/gem_generate_index_mus_musculus_mm10_$JOB_ID.err
#$ -pe smp 8
/software/mb/bin/gem-indexer -i /users/GR/mb/jquilez/assemblies/mus_musculus/mm10/ucsc/mm10.fa -o /users/GR/mb/jquilez/assemblies/mus_musculus/mm10/ucsc/mm10.gem -T 8
