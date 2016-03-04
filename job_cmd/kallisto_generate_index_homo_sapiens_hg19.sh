#!/bin/bash
#$ -N kallisto_generate_index_homo_sapiens_hg19
#$ -q short-sl65
#$ -l virtual_free=100G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/kallisto_generate_index_homo_sapiens_hg19_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/kallisto_generate_index_homo_sapiens_hg19_$JOB_ID.err
#$ -pe smp 2
/software/mb/bin/kallisto index -i /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/kallisto_index/kallisto_homo_sapiens_hg19_ensGene.index /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/ucsc/hg19_ensGene.fa.gz
