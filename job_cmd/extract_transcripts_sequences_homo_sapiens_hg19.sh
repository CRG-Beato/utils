#!/bin/bash
#$ -N extract_transcripts_sequences_homo_sapiens_hg19
#$ -q short-sl65
#$ -l virtual_free=10G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/extract_transcripts_sequences_homo_sapiens_hg19_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/extract_transcripts_sequences_homo_sapiens_hg19_$JOB_ID.err
#$ -pe smp 1
/software/mb/bin/gtf2bed -r /users/GR/mb/jquilez/utils/tmp_dir < <(grep -P '\ttranscript\t' /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/gencode/gencode.v19.annotation.gtf | grep -vP '^chrY' | grep -vP '^chrM') > /users/GR/mb/jquilez/utils/tmp_dir/tmp_gencode.v19.annotation.bed
/software/mb/bin/bedtools getfasta -fi /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/ucsc/hg19.fa -bed /users/GR/mb/jquilez/utils/tmp_dir/tmp_gencode.v19.annotation.bed -split -name -fo /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/gencode/gencode.v19.annotation.fa
gzip -f /users/GR/mb/jquilez/assemblies/homo_sapiens/hg19/gencode/gencode.v19.annotation.fa
rm -fr /users/GR/mb/jquilez/utils/tmp_dir
