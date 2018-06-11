#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_fastqc.sh
# Authors: Javier Quilez (GitHub: jaquol), JL Villanueva (GitHub: egenomics)
# Goal: generate quality control statistics from the FastQC log out file
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables
analysis=$1
shift
release_date=$1
shift
integrate_metadata=$1
shift
email=$1
shift
data_type=$1
shift
project=$1
shift
sequencing_type=$1
shift
samples="$@"

# paths
if [[ $project == "4DGenome" ]]; then
	ANALYSIS=/users/project/4DGenome/analysis/$analysis
	FASTQC=/users/project/4DGenome/sequencing/$release_date/fastqc
else
	IODIR=/users/mbeato/projects/data/$data_type/raw/$release_date
	ANALYSIS=/users/mbeato/projects/projects/$project/analysis/$analysis
	FASTQC=/users/mbeato/projects/data/$data_type/raw/$release_date/fastqc
fi
mkdir -p $ANALYSIS/tables
otab=$ANALYSIS/tables/fastq_quality_control_stats_fastqc.txt


#==================================================================================================
# COMMANDS
#==================================================================================================

echo "... FASTQ quality control stats for a set of samples saved in $otab"

# output file
if [[ $sequencing_type == "PE" ]]; then
	echo -e "sample_id\tread1_sequences\tread2_sequences\tread1_p_deduplicated\tread2_p_deduplicated" > $otab
else
	echo -e "sample_id\tread1_sequences\tread1_p_deduplicated" > $otab
fi

for s in $samples; do

	read1=$FASTQC/${s}_read1_fastqc/fastqc_data.txt
	read1_n_seqs=`cat $read1 | grep "Total Sequences" | sed "s/[^0-9]//g"`
	read1_p_dedup=`cat $read1 | grep "Total Deduplicated Percentage" | sed "s/[^0-9.]//g"`

	if [[ $sequencing_type == "PE" ]]; then
		read2=$FASTQC/${s}_read2_fastqc/fastqc_data.txt
		read2_n_seqs=`cat $read2 | grep "Total Sequences" | sed "s/[^0-9]//g"`
		read2_p_dedup=`cat $read2 | grep "Total Deduplicated Percentage" | sed "s/[^0-9.]//g"`
		echo -e "$s\t$read1_n_seqs\t$read2_n_seqs\t$read1_p_dedup\t$read2_p_dedup" >> $otab
	else
		echo -e "$s\t$read1_n_seqs\t$read1_p_dedup" >> $otab
	fi

done
