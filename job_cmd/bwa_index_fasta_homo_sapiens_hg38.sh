#!/bin/bash
#$ -N bwa_index_fasta_homo_sapiens_hg38
#$ -q short-sl65
#$ -l virtual_free=20G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/bwa_index_fasta_homo_sapiens_hg38_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/bwa_index_fasta_homo_sapiens_hg38_$JOB_ID.err
#$ -pe smp 1
/software/mb/el6.3/bwa/bwa-0.7.12/bwa index /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/ucsc/hg38.fa
