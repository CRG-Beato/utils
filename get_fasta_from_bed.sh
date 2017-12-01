#!/bin/bash


#==================================================================================================
# Created on: 2017-12-01
# Usage: ./get_fasta_from_bed.sh
# Author: javier.quilez@crg.eu
# Goal: get FASTA sequence for each entry in a BED file
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
process=get_fasta_from_bed
ibed=$HOME/assemblies/homo_sapiens/hg38/pirna_cluster_db/proTRAC_normal_ovary_and_testis_generic_clusterd_piRNAs.bed
ifa=$HOME/assemblies/homo_sapiens/hg38/ucsc/hg38_chr1-22XYMUn.fa
ofa=$HOME/assemblies/homo_sapiens/hg38/pirna_cluster_db/hg38_pirnas.fa

# Paths
JOB_CMD=$HOME/utils/job_cmd 
JOB_OUT=$HOME/utils/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
bedtools=`which bedtools`

# CRG cluster parameters
queue=short-sl7
memory=10G
max_time=06:00:00
slots=1



#==================================================================================================
# JOB
#==================================================================================================

# Build job: parameters
job_name=${process}
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

# build kallisto index
job_cmd="$bedtools getfasta -fi $ifa -bed $ibed -fo $ofa"
echo $job_cmd >> $job_file

# Submit job
chmod a+x $job_file 
qsub < $job_file

