#!/bin/bash
#$ -N kallisto_generate_index_homo_sapiens_hg38
#$ -q short-sl65
#$ -l virtual_free=10G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/kallisto_generate_index_homo_sapiens_hg38_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/kallisto_generate_index_homo_sapiens_hg38_$JOB_ID.err
#$ -pe smp 1
/software/mb/bin/kallisto index -i /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/kallisto_index/kallisto_homo_sapiens_hg38_gencode_v24.index /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/gencode/gencode.v24.transcripts.fa.gz
