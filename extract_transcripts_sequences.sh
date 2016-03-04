#!/bin/bash


#==================================================================================================
# Created on: 2015-12-22
# Usage: ./extract_transcripts_sequences.sh
# Author: javier.quilez@crg.eu
# Goal: uses GTF file (with genomic coordinates) to extract transcript sequences in FASTA
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables 
process="extract_transcripts_sequences"
species="homo_sapiens"
version="hg19"

# Paths
transcripts=$HOME/assemblies/$species/$version/gencode/gencode.v19.annotation
genome_fasta=$HOME/assemblies/$species/$version/ucsc/$version.fa
transcript_fasta=
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
TMP_DIR=$HOME/utils/tmp_dir
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
mkdir -p $TMP_DIR
gtf2bed=`which gtf2bed`
bedtools=`which bedtools`

# CRG cluster parameters
queue=short-sl65
memory=10G
max_time=06:00:00
slots=1



#==================================================================================================
# JOB
#==================================================================================================

# Build job: parameters
job_name=${process}_${species}_${version}
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

# convert GTF to BED12
tbed=$TMP_DIR/tmp_gencode.v19.annotation.bed
job_cmd="$gtf2bed -r $TMP_DIR < <(grep -P '\ttranscript\t' $transcripts.gtf | grep -vP '^chrY' | grep -vP '^chrM') > $tbed"
echo $job_cmd >> $job_file

# extract FASTA from BED12 and compress
ofa=$transcripts.fa 
job_cmd="$bedtools getfasta -fi $genome_fasta -bed $tbed -split -name -fo $ofa"
echo $job_cmd >> $job_file
job_cmd="gzip -f $ofa"
echo $job_cmd >> $job_file

# remove temporary directory
echo "rm -fr $TMP_DIR" >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file
