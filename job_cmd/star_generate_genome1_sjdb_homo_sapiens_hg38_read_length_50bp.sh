#!/bin/bash
#$ -N star_generate_genome1_sjdb_homo_sapiens_hg38_read_length_50bp
#$ -q short-sl65
#$ -l virtual_free=50G
#$ -l h_rt=06:00:00
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o /users/GR/mb/jquilez/utils/job_out/star_generate_genome1_sjdb_homo_sapiens_hg38_read_length_50bp_$JOB_ID.out
#$ -e /users/GR/mb/jquilez/utils/job_out/star_generate_genome1_sjdb_homo_sapiens_hg38_read_length_50bp_$JOB_ID.err
#$ -pe smp 8
/software/mb/bin/star --version
/software/mb/bin/star --runMode genomeGenerate --genomeDir /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/star_genome_index/read_length_50bp --genomeFastaFiles /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/ucsc/hg38_chr1-22XYMUn.fa --runThreadN 8 --sjdbOverhang 50 --sjdbGTFfile /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/gencode/gencode.v24.annotation.gtf --outFileNamePrefix /users/GR/mb/jquilez/assemblies/homo_sapiens/hg38/star_genome_index/read_length_50bp/
