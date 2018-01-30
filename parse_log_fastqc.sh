#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_fastqc.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: generate quality control statistics from the FastQC log out file
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables
samples="rf_001_01_01_chipseq rf_002_01_01_chipseq rf_003_01_01_chipseq rf_004_01_01_chipseq rf_005_01_01_chipseq"
data_type=chipseq
release_date=2016-02-04
project=rferrari
analysis=2016-02-08_get_and_quality_control_fastqs
sequencing_type="SE"

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

