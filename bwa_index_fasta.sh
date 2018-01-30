#!/bin/bash


#==================================================================================================
# Created on: 2016-01-19
# Usage: ./bwa_index_fasta.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: generates BWA index for the FASTA sequence of the genome
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables 
process="bwa_index_fasta"
species="mus_musculus"
version="mm10"
fasta_name=${version}_chr1-19XYMUn

# paths
genome_fasta=$HOME/assemblies/$species/$version/ucsc/$fasta_name.fa
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
bwa=`which bwa`

# CRG cluster parameters
queue=short-sl65
memory=20G
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

# STAR commands
job_cmd="$bwa index $genome_fasta"
echo $job_cmd >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file
#cat $job_file