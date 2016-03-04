#!/bin/bash


#==================================================================================================
# Created on: 2016-01-13
# Usage: ./parse_log_htseq.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: summary statistics for the transcript quantification using HTSeq
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Variables
samples="siCBX3_T0_1 siCBX3_T0_2 siCBX3_T6_1 siCBX3_T6_2 siCont_T0_CB siCont_T0_F siCont_T6_CB siCont_T6_F siFOXA1_T0_1 siFOXA1_T0_2 siFOXA1_T6_1 siFOXA1_T6_2"
#samples="siCBX3_T0_1"
data_type=rnaseq
project=brg1
analysis=2016-01-11_run_rnaseq_pipeline
program=htseq

# Paths 
SAMPLES=$HOME/data/$data_type/samples
ANALYSIS=$HOME/projects/$project/analysis/$analysis
otab=$ANALYSIS/tables/${program}_summary_stats.txt


#==================================================================================================
# COMMANDS
#==================================================================================================

echo "... ${program} stats for a set of samples saved in $otab"
echo -e "sample_id\tn_pairs_processed" > $otab

for s in $samples; do

	ilog=$SAMPLES/$s/logs/${s}_quantification_${program}.log
	n_pairs_processed=`grep "SAM alignment pairs processed" $ilog | sed "s/[^0-9]//g"`
	echo -e "$s\t$n_pairs_processed" >> $otab

done
