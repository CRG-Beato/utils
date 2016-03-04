#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_featurecounts.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: summary statistics for the transcript quantification using featureCounts
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables
samples="rf_01_01_rnaseq rf_01_02_rnaseq rf_01_03_rnaseq rf_01_04_rnaseq rf_01_05_rnaseq rf_01_07_rnaseq rf_01_09_rnaseq"
data_type=rnaseq
project=rferrari
analysis=2016-01-19_run_rnaseq_pipeline
program=featurecounts

# Paths 
SAMPLES=$HOME/data/$data_type/samples
ANALYSIS=$HOME/projects/$project/analysis/$analysis
otab=$ANALYSIS/tables/${program}_summary_stats.txt


#==================================================================================================
# COMMANDS
#==================================================================================================

echo "... ${program} stats for a set of samples saved in $otab"
echo -e "sample_id\tn_total_fragments\tn_assigned_fragments" > $otab

for s in $samples; do

	ilog=$SAMPLES/$s/logs/hg38/${s}_quantification_${program}.log
	n_total_fragments=`grep "Total fragments" $ilog | sed "s/[^0-9]//g"`
	n_assigned_fragments=`grep "Successfully assigned" $ilog | cut -f1 -d'(' | sed "s/[^0-9]//g"`
	echo -e "$s\t$n_total_fragments\t$n_assigned_fragments" >> $otab

done
