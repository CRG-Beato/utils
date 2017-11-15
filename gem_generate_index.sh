#!/bin/bash


#==================================================================================================
# Created on: 2016-03-24
# Usage: ./gem_generate_index.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: generates genome index files for GEM
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables 
process="gem_generate_index"
species="falco_peregrinus"
version="falPer2"
fasta_name=${version}
download_site=ncbi

# paths
genome_fasta=$HOME/assemblies/$species/$version/$download_site/$fasta_name.fa
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
gem_indexer=`which gem-indexer`
gem_index=$HOME/assemblies/$species/$version/$download_site/$fasta_name

# CRG cluster parameters
queue=short-sl7
memory=50G
max_time=06:00:00
slots=8



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
#$ -j y
#$ -o $m_out/${job_name}_\$JOB_ID.out
#$ -e $m_out/${job_name}_\$JOB_ID.err
#$ -pe smp $slots" > $job_file

# STAR commands
job_cmd="$gem_indexer -i $genome_fasta -o $gem_index -T $slots"
echo $job_cmd >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file
#cat $job_file