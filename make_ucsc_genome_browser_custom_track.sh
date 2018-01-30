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

# possible combinations
# data_type = chipseq & track_type = peaks_macs2
# data_type = chipseq & track_type = peaks_macs2_without_control
# data_type = chipseq & track_type = peaks_zerone 
# data_type = chipseq & track_type = profiles
# data_type = chrrnaseq & track_type = profiles 
# data_type = rnaseq & track_type = profiles
# data_type = hic & track_type = ev1 
# data_type = hic  & track_type = tads 
# data_type = atactseq & track_type = profiles 
# data_type = atactseq & track_type = peaks_macs2_without_control 
# data_type = mnaseseq & track_type = profiles 
# data_type =  & track_type = 


# variables
samples="ps_029_02_01_chipseq ps_031_01_01_chipseq ps_032_01_01_chipseq"
data_type=chipseq
track_type=peaks_macs2
version=hg19
sequencing_type=single_end
autoScale=off
alwaysZero=on
viewLimits=0.0:1.0
maxHeightPixels=100:50:10
browser_position="chr2:11,647,074-11,810,080"
visibility=2

# paths
# script to access the Beato lab metadata
print_metadata_table=/users/mbeato/projects/utils/print_metadata_table.py
# script to access the 4DGenome metadata
io_metadata=/users/project/4DGenome/utils/io_metadata.sh
python=`which python`
bed2bb=`which bedToBigBed`
bedgraph_to_bigwig=`which bedGraphToBigWig`
if [[ $version == "hg38" || $version == "hg38_mmtv" ]]; then
	chrom_sizes=$HOME/assemblies/homo_sapiens/$version/ucsc/${version}_chr1-22XYMUn.chrom.sizes
elif [[ $version == "mm10" ]]; then
	chrom_sizes=$HOME/assemblies/mus_musculus/$version/ucsc/${version}_chr1-19XYM.chrom.sizes
elif [[ $version == "hg19" ]]; then
	chrom_sizes=$HOME/assemblies/homo_sapiens/$version/ucsc/${version}_chr1-22XYMUn.chrom.sizes
fi
narrow_peak_specification=$HOME/assemblies/misc/narrowPeak.as


#==================================================================================================
# COMMANDS
#==================================================================================================

echo
for s in $samples; do 

	if [[ $track_type == "peaks_macs2" && $data_type == "chipseq" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/with_control/$sequencing_type
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_peaks.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		obed=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# make UCSC Genome Browser custom track header
		if [[ $version == 'hg38_mmtv' ]]; then
			db=hg38
		elif [[ $version == 'hg19' ]]; then
			db=hg19
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

		# additionally convert narrowPeak to bigBed
		obb=`echo $obed |sed "s/narrowPeak/bb/g"`
		tbed=$ODIR/tmp.bed
		grep -v 'track\|browser' $obed |awk '{OFS="\t"; print $1,$2,$3,$4,int($9),$6,$7,$8,$9,$10}' > $tbed
		$bed2bb $tbed $chrom_sizes $obb -as=$narrow_peak_specification -type=bed6+4
		rm $tbed

		echo $url
		echo

	elif [[ $track_type == "peaks_macs2_without_control" && $data_type == "chipseq" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/sample_alone/$sequencing_type
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
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
				name='${sample_name} peaks (macs2) without control' \
				description='$sample_name ($s), peaks (MACS2 without control)' \
				visibility=1 \
				useScore=1 \
				db=$db \
				url=$url \
				color=26,27,27"
		echo $cmd > $obed
		cmd="browser position $browser_position"
		echo $cmd >> $obed

		# add file content while skipping calls in the mmtv_luciferase contig
		grep -v 'mmtv_luciferase\|chrUn' $ifile >> $obed

		# additionally convert narrowPeak to bigBed
		obb=`echo $obed |sed "s/narrowPeak/bb/g"`
		tbed=$ODIR/tmp.bed
		grep -v 'track\|browser' $obed |awk '{OFS="\t"; print $1,$2,$3,$4,int($9),$6,$7,$8,$9,$10}' > $tbed
		$bed2bb $tbed $chrom_sizes $obb -as=$narrow_peak_specification -type=bed6+4
		rm $tbed

		echo $url
		echo

	elif [[ $track_type == "peaks_zerone" && $data_type == "chipseq" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/zerone/$version/with_control
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_zerone.txt
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
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

	elif [[ $track_type == "profiles" ]] && [[ $data_type == "chipseq" ]]; then

		#SHARED_PATH=data/$data_type/samples/$s/profiles/$version
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${sample_name} rpms' \
				description='$sample_name, reads per million (RPM)'
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


	elif [[ $track_type == "profiles" && $data_type == "chrrnaseq" ]]; then

		#SHARED_PATH=data/$data_type/samples/$s/profiles/$version
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_unique_multiple_strand1_rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${s} strand1 rpms' \
				description='$s strand1, reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=$viewLimits \
				maxHeightPixels=$maxHeightPixels \
				color=51,102,255"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_unique_multiple_strand2_rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${s} strand2 rpms' \
				description='$s strand2, reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=-1.0:0.0 \
				negateValues=on \
				maxHeightPixels=$maxHeightPixels \
				color=245,61,0"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

	elif [[ $track_type == "tads" ]] && [[ $data_type == "hic" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/downstream/$version
		ifile=/users/project/4DGenome_no_backup/$SHARED_PATH/${s}_tads_allchr.bed.gz
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		fname=`basename $ifile |sed "s/.bed.gz//g"`
		obed=$ODIR/$fname.bed

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`

		# convert from BED to bigBED format
		# add file content while skipping calls in the mmtv_luciferase contig
		zcat $ifile |grep -v mmtv_luciferase |cut -f1-3 > $obed		
		obb=$ODIR/$fname.bb
		$bed2bb $obed $chrom_sizes $obb -type=bed3
		rm $obed

		# make UCSC Genome Browser custom track header
		if [[ $version == 'hg38_mmtv' ]]; then
			db=hg38
		fi
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname.bb"	
		cmd="track type=bigBed \
				name='${sample_name} TADs' \
				description='$sample_name ($s), TADs' \
				visibility=1 \
				db=$db \
				bigDataUrl=$url \
				color=0,102,204"
		echo $cmd
		cmd="browser position $browser_position"
		echo $cmd

	elif [[ $track_type == "ev1" ]] && [[ $data_type == "hic" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/downstream/$version
		ifile=/users/project/4DGenome_no_backup/$SHARED_PATH/${s}_ev_100kb.tsv.gz
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		fname=`basename $ifile |sed "s/.tsv.gz//g"`
		obed=$ODIR/$fname.bed

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`

		# convert to bedGraph format
		zcat $ifile |awk '{OFS="\t"; print $1,$2,$2+100000,$4}' > $obed
		obw=$ODIR/$fname.bw
		$bedgraph_to_bigwig $obed $chrom_sizes $obw
		rm $obed

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname.bw"
		cmd="track type=bigWig \
				name='${sample_name} EV1' \
				description='$sample_name, first eigenvalue (100 Kb)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=-1.0:0.0 \
				maxHeightPixels=$maxHeightPixels \
				color=204,102,0"
		echo $cmd
		cmd="browser position $browser_position"
		echo $cmd		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		#cp $ifile $ofile

	elif [[ $track_type == "profiles" && $data_type == "rnaseq" ]]; then

		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_unique_multiple_strand1_rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${s} strand1 rpms' \
				description='$s strand1, reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=$viewLimits \
				maxHeightPixels=$maxHeightPixels \
				color=51,102,255"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_unique_multiple_strand2_rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${s} strand2 rpms' \
				description='$s strand2, reads per million (RPM)'
				bigDataUrl=$url \
				alwaysZero=$alwaysZero \
				visibility=$visibility \
				autoScale=$autoScale \
				viewLimits=-1.0:0.0 \
				negateValues=on \
				maxHeightPixels=$maxHeightPixels \
				color=245,61,0"
		echo $cmd
		echo "browser position $browser_position"
		echo		

		# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
		cp $ifile $ofile

	elif [[ $track_type == "profiles" ]] && [[ $data_type == "atacseq" ]]; then

		#SHARED_PATH=data/$data_type/samples/$s/profiles/$version
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${sample_name} rpms' \
				description='$sample_name, reads per million (RPM)'
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

	elif [[ $track_type == "peaks_macs2_without_control" && $data_type == "atacseq" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/sample_alone/$sequencing_type
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
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
				name='${sample_name} peaks (macs2) without control' \
				description='$sample_name ($s), peaks (MACS2 without control)' \
				visibility=1 \
				useScore=1 \
				db=$db \
				url=$url \
				color=26,27,27"
		echo $cmd > $obed
		cmd="browser position $browser_position"
		echo $cmd >> $obed

		# add file content while skipping calls in the mmtv_luciferase contig
		grep -v 'mmtv_luciferase\|chrUn' $ifile >> $obed

		# additionally convert narrowPeak to bigBed
		obb=`echo $obed |sed "s/narrowPeak/bb/g"`
		tbed=$ODIR/tmp.bed
		grep -v 'track\|browser' $obed |awk '{OFS="\t"; print $1,$2,$3,$4,int($9),$6,$7,$8,$9,$10}' > $tbed
		$bed2bb $tbed $chrom_sizes $obb -as=$narrow_peak_specification -type=bed6+4
		rm $tbed

		echo $url
		echo

	elif [[ $track_type == "peaks_macs2_without_control" && $data_type == "dnaseq" ]]; then

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/sample_alone/$sequencing_type
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*.narrowPeak
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
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
				name='${sample_name} peaks (macs2) without control' \
				description='$sample_name ($s), peaks (MACS2 without control)' \
				visibility=1 \
				useScore=1 \
				db=$db \
				url=$url \
				color=26,27,27"
		echo $cmd > $obed
		cmd="browser position $browser_position"
		echo $cmd >> $obed

		# add file content while skipping calls in the mmtv_luciferase contig
		grep -v 'mmtv_luciferase\|chrUn' $ifile >> $obed

		# additionally convert narrowPeak to bigBed
		obb=`echo $obed |sed "s/narrowPeak/bb/g"`
		tbed=$ODIR/tmp.bed
		grep -v 'track\|browser' $obed |awk '{OFS="\t"; print $1,$2,$3,$4,int($9),$6,$7,$8,$9,$10}' > $tbed
		$bed2bb $tbed $chrom_sizes $obb -as=$narrow_peak_specification -type=bed6+4
		rm $tbed

		echo $url
		echo

	elif [[ $track_type == "profiles" ]] && [[ $data_type == "mnaseseq" ]]; then

		#SHARED_PATH=data/$data_type/samples/$s/profiles/$version
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type

		# input/output filez/directories
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/projects/file_transfer/$SHARED_PATH
		mkdir -p $ODIR
		ofile=$ODIR/$fname

		# convert SAMPLE_ID to SAMPLE_NAME (the latter is more meaningful biologically)
		sample_name=`$python $print_metadata_table input_metadata $s SAMPLE_NAME`

		# UCSC Genome Browser custom track description
		url="http://public-docs.crg.es/mbeato/jquilez/$SHARED_PATH/$fname"
		cmd="track type=bigWig \
				name='${sample_name} rpms' \
				description='$sample_name, reads per million (RPM)'
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

	echo

done