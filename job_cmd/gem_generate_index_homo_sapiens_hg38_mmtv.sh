#!/bin/bash
#$ -N gem_generate_index_homo_sapiens_hg38_mmtv
#$ -q short-sl65
#$ -l virtual_free=50G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/gem_generate_index_homo_sapiens_hg38_mmtv_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/gem_generate_index_homo_sapiens_hg38_mmtv_$JOB_ID.err
#$ -pe smp 8
/software/mb/bin/gem-indexer -i /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38_mmtv/ucsc/hg38_mmtv_chr1-22XYM.fa -o /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38_mmtv/ucsc/hg38_mmtv_chr1-22XYM.gem -T 8
