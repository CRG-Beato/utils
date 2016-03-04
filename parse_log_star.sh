#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_star.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: generate mapping summary statistics from the STAR log out file
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables
samples="rf_01_01_rnaseq rf_01_02_rnaseq rf_01_03_rnaseq rf_01_04_rnaseq rf_01_05_rnaseq rf_01_07_rnaseq rf_01_09_rnaseq"
data_type=rnaseq
project=rferrari
analysis=2016-01-19_run_rnaseq_pipeline

# Paths 
SAMPLES=$HOME/data/$data_type/samples
ANALYSIS=$HOME/projects/$project/analysis/$analysis
mkdir -p $ANALYSIS/tables
otab=$ANALYSIS/tables/mapping_stats_star.txt


#==================================================================================================
# COMMANDS
#==================================================================================================

echo "... mapping stats for a set of samples saved in $otab"
echo -e "sample_id\tn_input_reads\tn_uniquely_mapped_reads\tn_accepted_multimapping_reads" > $otab

for s in $samples; do

	#ilog=$SAMPLES/$s/alignments/star/${s}.Log.final.out
	ilog=$SAMPLES/$s/alignments/star/hg38/${s}.Log.final.out	
	# typically, number of reads after sequencing adapter and low-quality ends trimming
	n_input_reads=`grep "Number of input reads" $ilog | sed "s/[^0-9]//g"`
	# reads mapping to a single position in the genome
	n_uniquely_mapped_reads=`grep "Uniquely mapped reads number" $ilog | sed "s/[^0-9]//g"`
	# number of reads which align to N loci, where N is in the (1, X) range --X is defined as a STAR parameter
	# following ENCODE's recommended standards, I typically use X=20
	n_accepted_multimapping_reads=`grep "Number of reads mapped to multiple loci" $ilog | sed "s/[^0-9]//g"`
	echo -e "$s\t$n_input_reads\t$n_uniquely_mapped_reads\t$n_accepted_multimapping_reads" >> $otab

done
