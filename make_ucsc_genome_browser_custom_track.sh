#!/bin/bash


#==================================================================================================
# Created on: 2015-12-01
# Usage: ./make_ucsc_genome_browser_custom_track.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: (i) copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
# (ii) print the sample UCSC Genome Browser custom track description
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="ps_002_01_01_chrrnaseq ps_001_01_01_chrrnaseq ps_003_01_01_chrrnaseq ps_004_01_01_chrrnaseq"
data_type=chrrnaseq
track_type=profiles
version=hg19
sequencing_type=paired_end
track_file=bigBed
autoScale=off
alwaysZero=on
viewLimits=0.0:1.0
maxHeightPixels=100:50:10
browser_position="chr2:11,647,074-11,810,080"
visibility=2

# paths
print_metadata_table=/users/GR/mb/jquilez/utils/print_metadata_table.py
python=`which python`
bed2bb=`which bedToBigBed`
chrom_sizes=$HOME/assemblies/homo_sapiens/$version/ucsc/$version.chrom.sizes.autosomes.chr*



#==================================================================================================
# COMMANDS
#==================================================================================================

echo
for s in $samples; do 

	if [[ $track_type == "rpms" ]]; then

		SHARED_PATH=data/$data_type/samples/$s/rpms/$version/$sequencing_type

		# input/output filez/directories
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/GR/mb/jquilez/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${sample_name} rpms' \
				description='$sample_name ($s), reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=$viewLimits \
				maxHeightPixels=$maxHeightPixels \
				color=204,102,0"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

	elif [[ $track_type == "peaks_macs2" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/with_control
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}*.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/GR/mb/jquilez/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		obed=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# make UCSC Genome Browser custom track header
		if [[ $version == 'hg38_mmtv' ]]; then
			db=hg38
		fi
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"	
		cmd="track type=narrowPeak \
				name='${sample_name} peaks (macs2)' \
				description='$sample_name ($s), peaks (MACS2 with control)' \
				visibility=1 \
				useScore=1 \
				db=$db \
				url=$url \
				color=0,102,204"
		echo $cmd > $obed
		cmd="browser position $browser_position"
		echo $cmd >> $obed

		# add file content while skipping calls in the mmtv_luciferase contig
		grep -v mmtv_luciferase $ifile >> $obed

		echo $url
		echo

	elif [[ $track_type == "peaks_zerone" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/zerone/$version/with_control
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}_zerone.txt
		ODIR=/users/GR/mb/jquilez/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		obed=$ODIR/${s}.bed

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# make UCSC Genome Browser custom track header
		if [[ $version == 'hg38_mmtv' ]]; then
			db=hg38
		fi
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/${s}.bed"	
		cmd="track type=bedGraph \
				name='${sample_name} peaks (Zerone)' \
				description='$sample_name ($s), peaks (Zerone with control)' \
				visibility=1 \
				db=$db \
				url=$url \
				alwaysZero=$alwaysZero \
				autoScale=$autoScale \
				viewLimits=$viewLimits \
				maxHeightPixels=$maxHeightPixels \
				color=0,204,102"
		echo $cmd > $obed
		cmd="browser position $browser_position"
		echo $cmd >> $obed

		# add file content
		# skipping calls in the mmtv_luciferase contig
		# 
		grep -v '#\|mmtv_luciferase' $ifile | awk '$4 == 2' | awk '{OFS="\t"; print $1,$2-1,$3,$7}' >> $obed

		echo $url
		echo

	elif [[ $track_type == "profiles" ]]; then

		#SHARED_PATH=data/$data_type/samples/$s/profiles/$version
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# input/output filez/directories
		ifile=/users/GR/mb/jquilez/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/GR/mb/jquilez/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		#sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${s} rpms' \
				description='$s, reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=$viewLimits \
				maxHeightPixels=$maxHeightPixels \
				color=204,102,0"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

	fi 



done