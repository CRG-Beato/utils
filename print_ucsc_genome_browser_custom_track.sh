#!/bin/bash


#==================================================================================================
# Created on: 2015-12-01
# Usage: ./print_ucsc_genome_browser_custom_track.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: Print the sample UCSC Genome Browser custom track description
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# Samples
samples="NETseq.T0"
data_type="netseq"
track_type="rpm"
track_file="bigWig"

# UCSC Genome Browser parameters
#track_type=bigWig
DATA=http://public-docs.crg.es/mbeato/jquilez/data
#RPMS=http://public-docs.crg.es/mbeato/jquilez/data/chipseq/rpms
#PEAKS=http://public-docs.crg.es/mbeato/jquilez/data/chipseq/peaks
alwaysZero=on
#visibility_rpms=2
#visibility_peaks=1
autoScale=off
viewLimits=0.0:10.0
maxHeightPixels=75
browser_position="chr2:11,647,074-11,810,080"

declare -A sample_to_name
sample_to_name['T_0_ER_MCF_7_11730_CGATGT']='ER_T0_R5020'
sample_to_name['T_30_ER_R5020_11731_CAGATC']='ER_T30_R5020'
sample_to_name['T_0_PR_MCF_7_11728_ACAGTG']='PR_T0_R5020'
sample_to_name['T_30_PR_R5020_11729_GTGAAA']='PR_T30_R5020'
sample_to_name['T_0_ER_11829_GCCAAT']='ER_T0_E2'
sample_to_name['T_30_ER_E2_11830_CTTGTA']='ER_T30_E2'
sample_to_name['T_30_ER_RU_11831_TTAGGC']='ER_T30_RU'
sample_to_name['INPUT_T_0_MCF7_11832_GATCAG']='INPUT_T0'
sample_to_name['INPUT_T_30_MCF7_11833_ACTGAT']='INPUT_T30'
sample_to_name['NETseq.T0']='netseq_t0_rep1'
#sample_to_name['']=''

declare -A sample_to_color
sample_to_color['T_0_ER_MCF_7_11730_CGATGT']='0,0,255'
sample_to_color['T_30_ER_R5020_11731_CAGATC']='255,0,0'
sample_to_color['T_0_PR_MCF_7_11728_ACAGTG']='0,0,255'
sample_to_color['T_30_PR_R5020_11729_GTGAAA']='255,0,0'
sample_to_color['T_0_ER_11829_GCCAAT']='0,0,255'
sample_to_color['T_30_ER_E2_11830_CTTGTA']='255,0,0'
sample_to_color['T_30_ER_RU_11831_TTAGGC']='255,0,0'
sample_to_color['INPUT_T_0_MCF7_11832_GATCAG']='192,192,192'
sample_to_color['INPUT_T_30_MCF7_11833_ACTGAT']='192,192,192'
sample_to_color['NETseq.T0']='netseq_t0_rep1'
#sample_to_color['']=''


#==================================================================================================
# COMMANDS
#==================================================================================================

echo
for s in $samples; do

	if [[ $data_type == "netseq" ]]; then

		bigDataUrl=$DATA/$data_type/profiles/

	fi 
	
	# RPM profiles
	echo "track type=bigWig name=${sample_to_name[$s]} bigDataUrl=$RPMS/$s.rpm.bw alwaysZero=$alwaysZero visibility=$visibility_rpms color=${sample_to_color[$s]} autoScale=$autoScale viewLimits=$viewLimits maxHeightPixels=$maxHeightPixels"
	echo "browser position $browser_position"
	echo

	# MACS2 peaks
	if [[ $s == "INPUT_T_0_MCF7_11832_GATCAG" ]]; then continue
	elif [[ $s == "INPUT_T_30_MCF7_11833_ACTGAT" ]]; then continue
	else
		echo "track type=narrowPeak name=${sample_to_name[$s]}_peaks visibility=$visibility_peaks description=${sample_to_name[$s]}"
		echo "$PEAKS/macs2/${s}_peaks.narrowPeak"
		echo "browser position $browser_position"
	fi

done


