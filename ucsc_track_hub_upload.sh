#!/bin/bash


#==================================================================================================
# Created on: 2016-11-04
# Usage: ./ucsc_track_hub_upload.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: (i) copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
# (ii) print the sample UCSC Genome Browser custom track hub definition
#==================================================================================================

# this script is an evolution of, and aims to deprecate*, these 2 scripts:
# utils/make_ucsc_genome_browser_custom_track.sh
# utils/print_ucsc_track_hub_track_definition.sh
# *in terms of using them for uploading data to the browser



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="yc_001_01_01_chipseq"
data_type=chipseq
call_peaks_mode=
project=ycuartero

# paths
python=`which python`
bed2bb=`which bedToBigBed`
bedgraph_to_bigwig=`which bedGraphToBigWig`
bedtools=`which bedtools`
narrow_peak_specification=/users/mbeato/projects/assemblies/misc/narrowPeak.as



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
		io_metadata=/users/mbeato/projects/utils/io_metadata.sh
	fi

	# sample name
	sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`
	# cell line
	cell_line=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a CELL_TYPE`
	cell_line_new=`echo ${cell_line,,} |sed "s/-/_/g"`
	# treatment and treatment time
	# convert to the keys/values for the treatment time into those used in the track hub
	treatment=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT`
	treatment_time=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT_TIME`
	if [[ $treatment_time == '0' ]]; then treatment_time_new=t0000
	elif [[ $treatment_time == '5' ]]; then treatment_time_new=t0005
	elif [[ $treatment_time == '15' ]]; then treatment_time_new=t0015
	elif [[ $treatment_time == '30' ]]; then treatment_time_new=t0030
	elif [[ $treatment_time == '60' ]]; then treatment_time_new=t0060
	elif [[ $treatment_time == '180' ]]; then treatment_time_new=t0180
	elif [[ $treatment_time == '360' ]]; then treatment_time_new=t0360
	elif [[ $treatment_time == '720' ]]; then treatment_time_new=t0720
	elif [[ $treatment_time == '1440' ]]; then treatment_time_new=t1440
	fi
	# user
	user=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a USER`
	user_new=`echo ${user,,} |sed "s/ /_/g"`
	# sequencing type
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
		chrom_sizes=/users/mbeato/projects/assemblies/homo_sapiens/$version/ucsc/${version}_chr1-22XYMUn.chrom.sizes
		db=hg38
	elif [[ $species == "Mus_musculus" ]]; then
		version=mm10
		chrom_sizes=/users/mbeato/projects/assemblies/mus_musculus/$version/ucsc/${version}_chr1-19XYMUn.chrom.sizes
		db=mm10
	fi
	# target protein (only for non-4DGenome projects)
	if [[ $project != "4DGenome" ]]; then
		target_protein=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TARGET_PROTEIN`
		target_protein_new=`echo ${target_protein,,} |sed "s/chip-//g"`
	fi



	#==================================================================================================
	# ChIP-seq
	#==================================================================================================

	if [[ $data_type == "chipseq" ]]; then


		# read per per million profiles
		echo "... preparing read per million profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obw=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obw

		# print track hub definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_profile" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/$version/$sequencing_type_long/$s.rpm.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) RPM profile" >> $composite_track.txt
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi


		# peaks coordinates with -log10(FDR q-value)
		echo "... preparing peaks coordinates with -log10(FDR q-value)"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_peaks.narrowPeak
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR

		# convert to bigWig
		fname=`basename $ifile |sed "s/narrowPeak/bw/g"`
		tbed=$ODIR/tbed.bed
		obw=$ODIR/$fname
		grep -v mmtv_luciferase $ifile | cut -f1-3,9 |$bedtools groupby -i stdin -g 1,2,3 -c 4 -o mean > $tbed
		$bedgraph_to_bigwig $tbed $chrom_sizes $obw

		# print track hub definitions
		track_type=peaks_macs2_qvalues
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_$track_type" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long/${s}_peaks.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		if [[ $call_peaks_mode == "sample_alone" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 peaks without control, -log10(q-value)" >> $composite_track.txt
		elif [[ $call_peaks_mode == "with_control" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 peaks, -log10(q-value)" >> $composite_track.txt
		fi
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi


		# define paths
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_peaks.broadPeak
		if [ -f $ifile ]; then
		# peaks coordinates for broadpeaks
		echo "... preparing broad peaks coordinates with -log10(FDR q-value)"
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR

		# convert to bigWig
		fname=`basename $ifile | sed "s/.broadPeak/_broad.bw/g"`
		tbed=$ODIR/tbed.bed
		obw=$ODIR/$fname
		grep -v mmtv_luciferase $ifile | cut -f1-3,9 | $bedtools groupby -i stdin -g 1,2,3 -c 4 -o mean > $tbed
		$bedgraph_to_bigwig $tbed $chrom_sizes $obw

		# print track hub definitions
		track_type=peaks_macs2_qvalues
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_$track_type" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long/${s}_peaks_broad.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel ${sample_name}_broad" >> $composite_track.txt
		if [[ $call_peaks_mode == "sample_alone" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 broad peaks without control, -log10(q-value)" >> $composite_track.txt
		elif [[ $call_peaks_mode == "with_control" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 broad peaks, -log10(q-value)" >> $composite_track.txt
		fi
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi
	fi

		# alignments
		echo "... alignments profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/alignments/bwa/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_sorted_filtered.bam
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obam=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obam
		cp $ifile.bai $ODIR

		# print track hub definitions
		track_type=alignments
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_alignments" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/bwa/$version/$sequencing_type_long/${s}_sorted_filtered.bam" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) alignments BAM" >> $composite_track.txt
		echo -e "\t\ttype bam" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi

		echo



	#==================================================================================================
	# HiChIP-seq
	#==================================================================================================

	elif [[ $data_type == "hichipseq" ]]; then


		# read per per million profiles
		echo "... preparing read per million profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obw=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obw

		target_protein_new_no_hi=`echo ${target_protein_new,,} |sed 's/hi//g'`

		# print track hub definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_profile" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/$version/$sequencing_type_long/$s.rpm.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) RPM profile" >> $composite_track.txt
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new_no_hi} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi
		#echo >> $composite_track.txt


		# peaks coordinates with -log10(FDR q-value)
		echo "... preparing peaks coordinates with -log10(FDR q-value)"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_peaks.narrowPeak
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR

		# convert to bigWig
		fname=`basename $ifile |sed "s/narrowPeak/bw/g"`
		tbed=$ODIR/tbed.bed
		obw=$ODIR/$fname
		grep -v mmtv_luciferase $ifile | cut -f1-3,9 |$bedtools groupby -i stdin -g 1,2,3 -c 4 -o mean > $tbed
		$bedgraph_to_bigwig $tbed $chrom_sizes $obw

		# print track hub definitions
		track_type=peaks_macs2_qvalues
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_$track_type" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/peaks/macs2/$version/$call_peaks_mode/$sequencing_type_long/${s}_peaks.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		if [[ $call_peaks_mode == "sample_alone" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 peaks without control, -log10(q-value)" >> $composite_track.txt
		elif [[ $call_peaks_mode == "with_control" ]]; then
			echo -e "\t\tlongLabel $sample_name ($s) MACS2 peaks, -log10(q-value)" >> $composite_track.txt
		fi
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi


		# alignments
		echo "... alignments profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/alignments/bwa/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}_sorted_filtered.bam
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obam=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obam
		cp $ifile.bai $ODIR

		# print track hub definitions
		track_type=alignments
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_alignments" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/bwa/$version/$sequencing_type_long/${s}_sorted_filtered.bam" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) alignments BAM" >> $composite_track.txt
		echo -e "\t\ttype bam" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi

		echo



	#==================================================================================================
	# RNA-seq or ChrRNA-seq
	#==================================================================================================

	elif [[ $data_type == "rnaseq" || $data_type == "chrrnaseq" ]]; then


		# read per per million profiles
		echo "... preparing read per million profiles"

		# print track hub definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\ttrack ${s}_profile" >> $composite_track.txt
		echo -e "\tparent $composite_track" >> $composite_track.txt
		echo -e "\tcontainer multiWig" >> $composite_track.txt
		echo -e "\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\tlongLabel $sample_name ($s) RPM profile" >> $composite_track.txt
		echo -e "\ttype bigWig" >> $composite_track.txt
		echo -e "\tvisibility full" >> $composite_track.txt
        echo -e "\tautoscale off" >> $composite_track.txt
	    echo -e "\talwaysZero on" >> $composite_track.txt
       	echo -e "\tviewLimits -1.0:1.0" >> $composite_track.txt
  	   	echo -e "\taggregate transparentOverlay" >> $composite_track.txt
  	   	echo -e "\tshowSubtrackColorOnUi on" >> $composite_track.txt
  	   	echo -e "\tmaxHeightPixels 100:50:10" >> $composite_track.txt
  	   	echo -e "\tcolor 0,128,0" >> $composite_track.txt
   	    echo -e "\tpriority 6" >> $composite_track.txt
   	    echo >> $composite_track.txt

   	    strands="strand1 strand2"

   	    for strand in $strands; do

			# input/output filez/directories
			SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
			ifile=/users/mbeato/projects/$SHARED_PATH/${s}_unique_multiple_${strand}_rpm.bw
			fname=`basename $ifile`
			ODIR=/users/mbeato/public-docs/$SHARED_PATH
			mkdir -p $ODIR
			ofile=$ODIR/$fname

			# copy data to the `file_transfer` directory, which is accessible for the UCSC Genome browser
			cp $ifile $ofile

			echo -e "\t\ttrack ${s}_profile_${strand}" >> $composite_track.txt
			echo -e "\t\tparent ${s}_profile" >> $composite_track.txt
			echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/$version/$sequencing_type_long/${s}_unique_multiple_${strand}_rpm.bw" >> $composite_track.txt
			echo -e "\t\ttype bigWig" >> $composite_track.txt
  	    	echo -e "\t\tcolor 0,128,0" >> $composite_track.txt
  	    	if [[ $strand == "strand2" ]]; then
				echo -e "\t\tnegateValues on" >> $composite_track.txt
			fi

	   	    echo >> $composite_track.txt

		done


		# alignments
		echo "... alignments profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/alignments/star/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}.Aligned.sortedByCoord.out.bam
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obam=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obam
		cp $ifile.bai $ODIR

		# print track hub definitions
		track_type=alignments
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_alignments" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/star/$version/$sequencing_type_long/${s}.Aligned.sortedByCoord.out.bam" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) alignments BAM" >> $composite_track.txt
		echo -e "\t\ttype bam" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi

		echo



	#==================================================================================================
	# ATAC-seq
	#==================================================================================================

	elif [[ $data_type == "atacseq" ]]; then


		# read per per million profiles
		echo "... preparing read per million profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obw=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obw

		# print track hub definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_profile" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/$version/$sequencing_type_long/$s.rpm.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) RPM profile" >> $composite_track.txt
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi



	#==================================================================================================
	# DNAse-seq
	#==================================================================================================

	elif [[ $data_type == "dnaseseq" ]]; then


		# read per per million profiles
		echo "... preparing read per million profiles"

		# define paths
		SHARED_PATH=data/$data_type/samples/$s/profiles/$version/$sequencing_type_long
		ifile=/users/mbeato/projects/$SHARED_PATH/${s}*rpm.bw
		fname=`basename $ifile`
		ODIR=/users/mbeato/public-docs/$SHARED_PATH
		mkdir -p $ODIR
		obw=$ODIR/$fname

		# copy data to the `file_transfer` directory
		cp $ifile $obw

		# print track hub definitions
		track_type=profiles
		composite_track=${data_type}_$track_type
		echo -e >> $composite_track.txt
		echo -e "\t\ttrack ${s}_profile" >> $composite_track.txt
		echo -e "\t\tparent $composite_track" >> $composite_track.txt
		echo -e "\t\tbigDataUrl https://data:adenine&thymine@public_docs.crg.es/mbeato/public-docs/data/$data_type/samples/$s/$track_type/$version/$sequencing_type_long/$s.rpm.bw" >> $composite_track.txt
		echo -e "\t\tshortLabel $sample_name" >> $composite_track.txt
		echo -e "\t\tlongLabel $sample_name ($s) RPM profile" >> $composite_track.txt
		echo -e "\t\ttype bigWig" >> $composite_track.txt
		if [[ $project != "4DGenome" ]]; then
			echo -e "\t\tsubGroups cell_line=$cell_line_new antibody=${target_protein_new,,} treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		else
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new" >> $composite_track.txt
		fi
	fi

done
