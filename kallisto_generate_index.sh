#!/bin/bash


#==================================================================================================
# Created on: 2015-12-18
# Usage: ./kallisto_generate_index.sh
# Author: javier.quilez@crg.eu
# Goal: generates genome index files for kallisto
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables 
process="kallisto_generate_index"
species="homo_sapiens"
version="hg38"

# Paths 
KALLISTO=$HOME/assemblies/$species/$version/kallisto_index
if [[ $version == "hg19" ]]; then
	transcripts_fasta=$HOME/assemblies/$species/$version/ucsc/${version}_ensGene.fa.gz
	index=$KALLISTO/kallisto_${species}_${version}_ensGene.index
elif [[ $version == "hg38" ]]; then
	transcripts_fasta=$HOME/assemblies/$species/$version/gencode/gencode.v24.transcripts.fa.gz
	index=$KALLISTO/kallisto_${species}_${version}_gencode_v24.index
fi
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
mkdir -p $KALLISTO
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
kallisto=`which kallisto`

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

# build kallisto index
job_cmd="$kallisto index -i $index $transcripts_fasta"
echo $job_cmd >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file