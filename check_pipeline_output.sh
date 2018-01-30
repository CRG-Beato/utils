#!/bin/bash


#==================================================================================================
# Created on: 2016-06-08
# Usage: ./check_pipeline_output.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: prints pipeline's output, other than those reporting INFO and TIME, for a given sample
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
sample=$1
pipeline=$2
run_on=$3





#==================================================================================================
# COMMANDS
#==================================================================================================

echo
echo
echo $sample

if [[ "$pipeline" == 'chipseq' ]]; then

	# paths 
	SAMPLE=$HOME/data/*/samples/$sample
	ilog=$HOME/pipelines/$pipeline-16.04/job_out/job_${sample}_${run_on}*out
	ibam=$SAMPLE/alignments/bwa/*/*/${sample}_sorted_filtered.bam
	ibai=$SAMPLE/alignments/bwa/*/*/${sample}_sorted_filtered.bam.bai
	ibw=$SAMPLE/profiles/*/*/$sample.rpm.bw
	ibed=$SAMPLE/peaks/macs2/*/*/*/${sample}_peaks.narrowPeak

	# error checks
	cat $ilog |grep -v "TIME\|INFO" |grep -v 'mem_pestat' |sed '/^\s*$/d'
	ls -lh $ibam |cut -f5-20 -d' '
	ls -lh $ibai |cut -f5-20 -d' '
	ls -lh $ibw |cut -f5-20 -d' '
	ls -lh $ibed |cut -f5-20 -d' '

elif [[ "$pipeline" == 'rnaseq' ]]; then

	# paths
	SAMPLE=$HOME/data/rnaseq/samples/$sample
	ilog=$HOME/pipelines/$pipeline-16.06/job_out/${sample}_${run_on}*out
	ibam=$SAMPLE/alignments/star/*/*/$sample.Aligned.sortedByCoord.out.bam
	ibai=$SAMPLE/alignments/star/*/*/$sample.Aligned.sortedByCoord.out.bam.bai
	ibw1=$SAMPLE/profiles/*/*/${sample}_unique_multiple_strand1_rpm.bw
	ibw2=$SAMPLE/profiles/*/*/${sample}_unique_multiple_strand2_rpm.bw
	itsv=$SAMPLE/quantifications/kallisto/*/*/abundance.tsv

	# error checks
	cat $ilog |grep -v "TIME\|INFO" |grep -v 'mem_pestat' |sed '/^\s*$/d'
	ls -lh $ibam |cut -f5-20 -d' '
	ls -lh $ibai |cut -f5-20 -d' '
	ls -lh $ibw1 |cut -f5-20 -d' '
	ls -lh $ibw2 |cut -f5-20 -d' '
	ls -lh $itsv |cut -f5-20 -d' '

fi

echo
echo
