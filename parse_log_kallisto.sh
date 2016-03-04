#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_kallisto.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: summary statistics for the transcript quantification using kallisto
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
otab=$ANALYSIS/tables/kallisto_summary_stats.txt


#==================================================================================================
# COMMANDS
#==================================================================================================

echo "... kallisto stats for a set of samples saved in $otab"
echo -e "sample_id\tn_processed\tn_pseudoaligned" > $otab

for s in $samples; do

	ilog=$SAMPLES/$s/logs/${s}_quantification_kallisto.log
	ilog=$SAMPLES/$s/logs/hg38/${s}_quantification_kallisto.log
	n_processed=`grep "pseudoaligned" $ilog | sed "s/ reads, /;/g" | sed "s/[^0-9;]//g" |cut -f1 -d';'`
	n_pseudoaligned=`grep "pseudoaligned" $ilog | sed "s/ reads, /;/g" | sed "s/[^0-9;]//g" |cut -f2 -d';'`
	echo -e "$s\t$n_processed\t$n_pseudoaligned" >> $otab

done
