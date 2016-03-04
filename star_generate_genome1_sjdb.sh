#!/bin/bash


#==================================================================================================
# Created on: 2015-11-27
# Usage: ./star_generate_genome1_sjdb.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: generates genome index files for STAR aligner using a known splice junctions database (sjdb)
#==================================================================================================

# workflow:
# the assembly version (1) reference sequence and (2) gene annotation are passed to STAR
# note that for the `*_mmtv` assembly versions (whose reference sequence include that of the MMTV)
# we used the gene annotation of the assembly without the MMTV



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables 
process="star_generate_genome1_sjdb"
species="homo_sapiens"
version="hg19"
read_length=100

# Paths
GENOME_DIR=$HOME/assemblies/$species/$version/star_genome_index/read_length_${read_length}bp
genome_fasta=$HOME/assemblies/$species/$version/ucsc/$version.fa
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
mkdir -p $GENOME_DIR
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
star=`which STAR`

# define gene annoation file based on the assembly version 
if [[ $version == "hg19" ]]; then 
	sjdb=$HOME/assemblies/$species/$version/gencode/gencode.v19.annotation.gtf
elif [[ $version == "hg19_mmtv" ]]; then 
	sjdb=$HOME/assemblies/$species/hg19/gencode/gencode.v19.annotation.gtf
elif [[ $version == "hg38" ]]; then
	sjdb=$HOME/assemblies/$species/$version/gencode/gencode.v24.annotation.gtf
elif [[ $version == "hg38_mmtv" ]]; then
	sjdb=$HOME/assemblies/$species/hg38/gencode/gencode.v24.annotation.gtf
fi 

# CRG cluster parameters
queue=short-sl65
memory=50G
max_time=06:00:00
slots=8



#==================================================================================================
# JOB
#==================================================================================================

# Build job: parameters
job_name=${process}_${species}_${version}_read_length_${read_length}bp
job_file=$JOB_CMD/$job_name.sh
m_out=$JOB_OUT
echo "#!/bin/bash
#$ -N $job_name
#$ -q $queue
#$ -l virtual_free=$memory
#$ -l h_rt=$max_time
#$ -M javier.quilez@crg.eu
#$ -m abe
#$ -o $m_out/${job_name}_\$JOB_ID.out
#$ -e $m_out/${job_name}_\$JOB_ID.err
#$ -pe smp $slots" > $job_file

# STAR commands
echo "`echo $star --version`" >> $job_file
job_cmd="$star \
 			--runMode genomeGenerate \
 			--genomeDir $GENOME_DIR \
 			--genomeFastaFiles $genome_fasta \
 			--runThreadN $slots \
 			--sjdbOverhang $read_length \
 			--sjdbGTFfile $sjdb \
 			--outFileNamePrefix $GENOME_DIR/"
echo $job_cmd >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file