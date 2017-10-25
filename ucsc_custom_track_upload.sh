#!/bin/bash


#==================================================================================================
# Created on: 2017-10-25
# Usage: ./ucsc_custom_track_upload.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: (i) copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
# (ii) print the sample UCSC Genome Browser custom track definition
#==================================================================================================




#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="ag_011_01_03_chipseq ag_011_02_03_chipseq ag_012_01_03_chipseq ag_012_02_03_chipseq ag_013_01_03_chipseq ag_013_02_03_chipseq ag_014_01_03_chipseq ag_014_02_03_chipseq"
data_type=chipseq
call_peaks_mode=with_control
project=argentina

# paths
python=`which python`




#==================================================================================================
# COMMANDS
#==================================================================================================

echo
for s in $samples; do

	echo $s

	#==================================================================================================
	# Retrieve metadata
	#==================================================================================================

	echo "... retrieving metadata"

	# script to access the metadata
	if [[ $project == "4DGenome" ]]; then
		io_metadata=/users/project/4DGenome/utils/io_metadata.sh
	else
		io_metadata=/users/GR/mb/jquilez/utils/io_metadata.sh
	fi

	# sample name & metadata
	sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`
	sequencing_type=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SEQUENCING_TYPE`
	if [[ $sequencing_type == 'SE' ]]; then
		sequencing_type_long=single_end
	elif [[ $sequencing_type == 'PE' ]]; then
		sequencing_type_long=paired_end
	fi
	# species and chromosomes lengths
	species=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SPECIES`
	if [[ $species == "Homo_sapiens" ]]; then
		version=hg38_mmtv
		chrom_sizes=/users/GR/mb/jquilez/assemblies/homo_sapiens/$version/ucsc/${version}_chr1-22XYMUn.chrom.sizes
		db=hg38
	elif [[ $species == "Mus_musculus" ]]; then
		version=mm10
		chrom_sizes=/users/GR/mb/jquilez/assemblies/mus_musculus/$version/ucsc/${version}_chr1-19XYMUn.chrom.sizes
		db=mm10
	fi




	#==================================================================================================
	# ChIP-seq
	#==================================================================================================

	if [[ $data_type == "chipseq" ]]; then

	
		# read per per million profiles
		echo "... preparing read per million profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/GR/mb/jquilez/file_transfer/open_access/$project
		mkdir -p $ODIR
		obw=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obw

		# print custom track definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		url=https://public-docs.crg.es/mbeato/jquilez/open_access/$project/$fname
		echo "track type=bigWig name='${sample_name} profiles' bigDataUrl=$url alwaysZero=on visibility=2 autoScale=off viewLimits=0.0:1.0 maxHeightPixels=50" >> $composite_track.txt

		# peaks coordinates 
		echo "... preparing peaks coordinates"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}_peaks.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/GR/mb/jquilez/file_transfer/open_access/$project
		mkdir -p $ODIR
		obed=$ODIR/$fname

		url="http://public-docs.crg.es/mbeato/jquilez/open_access/$project/$fname"	
		cmd="track type=narrowPeak \
				name='${sample_name} peaks (macs2)' \
				visibility=1 \
				useScore=1 \
				db=hg38 \
				url=$url \
				color=0,102,204"
		echo $cmd > $obed

		# add file content while skipping calls in the mmtv_luciferase contig
		grep -v mmtv_luciferase $ifile >> $obed

		# print track hub definitions
		track_type=peaks_macs2
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo $url >> $composite_track.txt
		echo

	fi

done




