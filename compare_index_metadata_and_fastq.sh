#!/bin/bash


#==================================================================================================
# Created on: 2017-12-15
# Usage: ./compare_index_metadata_and_fastq.sh
# Author: javier.quilez@crg.eu
# Goal: Compare the sequencing index in the metadata and in the FASTQ file
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="ALA_1 ALA_2 ALA_3 ALA_10 ALA_11 ALA_12 ALA_13 ALA_14 ALA_15 ALA_16 ALA_17"
project=4DGenome



#==================================================================================================
# COMMANDS
#==================================================================================================

for s in $samples; do

	echo
	echo $s

	if [[ "$project" == '4DGenome' ]]; then
	
		# input dir
		IDIR=/users/project/4DGenome
		
		# script to extract metadata
		io_metadata=$IDIR/utils/io_metadata.sh

		# locate FASTQ file (only read1 is needed for paired-end)
		ifq=$IDIR/sequencing/*/${s}_read1.fastq.gz

	else

		# input dir
		IDIR=/users/GR/mb/jquilez

		# script to extract metadata
		io_metadata=$IDIR/utils/io_metadata.sh

		# locate FASTQ file (only read1 is needed for paired-end)
		ifq=$IDIR/data/*/raw/*/${s}_read1.fastq.gz

	fi	


	# get index sequence from the metadata
	echo "index from the metadata:"
	$io_metadata -m get_from_metadata -s $s -t input_metadata -a 'SEQUENCING_INDEX'
	echo

	# get index sequence from the FASTQ
	echo "index in the first FASTQ read (used to check for consistency between metadata and FASTQ):"
	zcat $ifq |grep '^@' |cut -f10 -d':' |head -n 1
	echo
	echo "index in the first 100 FASTQ reads:"	
	zcat $ifq |grep '^@' |cut -f10 -d':' |head -n 100 |sort |uniq -c

	echo

done


