#!/bin/bash


#==================================================================================================
# Created on: 2015-12-01
# Usage: ./print_ucsc_track_hub_track_definition.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: 
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
project=fdily
samples="fd_004_01_01_rnaseq fd_004_02_01_rnaseq fd_004_03_01_rnaseq fd_005_01_01_rnaseq fd_005_02_01_rnaseq fd_005_03_01_rnaseq fd_006_01_01_rnaseq fd_006_02_01_rnaseq fd_006_03_01_rnaseq fd_010_01_01_rnaseq fd_010_02_01_rnaseq"
data_type=rnaseq
track_type=profiles
version=hg38_mmtv
sequencing_type=paired_end
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
chrom_sizes=$HOME/assemblies/homo_sapiens/$version/ucsc/${version}_chr1-22XYMUn.chrom.sizes
narrow_peak_specification=$HOME/assemblies/misc/narrowPeak.as


#==================================================================================================
# COMMANDS
#==================================================================================================

super_track=$data_type
composite_track=${data_type}_${track_type}

echo
for s in $samples; do

	if [[ $project == "4DGenome" ]]; then

		# script to access the 4DGenome metadata
		io_metadata=/users/project/4DGenome/utils/io_metadata.sh

		# get metadata
		sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`
		cell_line=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a CELL_TYPE`
		treatment=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT`
		treatment_time=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT_TIME`
		user=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a USER`

		# convert to the keys/values for the treatment time into those used in the track hub
		# treatment time
		if [[ $treatment_time == '0' ]]; then treatment_time_new=t0000
		elif [[ $treatment_time == '5' ]]; then treatment_time_new=t0005
		elif [[ $treatment_time == '15' ]]; then treatment_time_new=t0015
		elif [[ $treatment_time == '30' ]]; then treatment_time_new=t0030
		elif [[ $treatment_time == '60' ]]; then treatment_time_new=t0060
		elif [[ $treatment_time == '180' ]]; then treatment_time_new=t0180
		elif [[ $treatment_time == '360' ]]; then treatment_time_new=t0360
		elif [[ $treatment_time == '1440' ]]; then treatment_time_new=t1440
		fi
		# user
		user_new=`echo ${user,,} |sed "s/ /_/g"`
		# cell line
		cell_line_new=`echo ${cell_line,,} |sed "s/-/_/g"`

		if [[ $composite_track == "hic_ev1" ]]; then 

			echo -e "\t\ttrack ${s}_hic_ev1"
			echo -e "\t\tparent $composite_track"
			echo -e "\t\tbigDataUrl ../../$data_type/samples/$s/downstream/$version/${s}_ev_100kb.bw"
			echo -e "\t\tshortLabel $sample_name ($s)"
			echo -e "\t\tlongLabel $s ($sample_name) EV1"
			echo -e "\t\ttype bigWig"
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new"
			echo

		elif [[ $composite_track == "hic_tads" ]]; then 

			echo -e "\t\ttrack ${s}_hic_tads"
			echo -e "\t\tparent $composite_track"
			echo -e "\t\tbigDataUrl ../../$data_type/samples/$s/downstream/$version/${s}_tads_allchr.bb"
			echo -e "\t\tshortLabel $sample_name ($s)"
			echo -e "\t\tlongLabel $sample_name ($s) TADs"
			echo -e "\t\ttype bigBed"
			echo -e "\t\tsubGroups cell_line=$cell_line_new treatment_time=$treatment_time_new treatment=${treatment,,} user=$user_new"
			echo

		fi		

	else

		# script to access the 4DGenome metadata
		io_metadata=/users/GR/mb/jquilez/utils/io_metadata.sh

		# get metadata
		sample_name=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SAMPLE_NAME`
		cell_line=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a CELL_TYPE`
		treatment=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT`
		treatment_time=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a TREATMENT_TIME`
		user=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a USER`

		if [[ $composite_track == "chipseq_profiles" ]]; then 

			echo -e "\t\ttrack ${s}_profile"
			echo -e "\t\tparent $composite_track"
			echo -e "\t\tbigDataUrl ../../$data_type/samples/$s/$track_type/$version/$sequencing_type/$s.rpm.bw"
			echo -e "\t\tshortLabel $sample_name"
			echo -e "\t\tlongLabel $sample_name ($s) RPM profile"
			echo -e "\t\ttype bigWig"
			echo -e "\t\tsubGroups cell_line=$cell_line antibody=${target_protein_new,,} treatment_time=$treatment_time_new"
			echo

		elif [[ $composite_track == "rnaseq_profiles" ]]; then

			echo -e "\ttrack ${s}_profile"
			echo -e "\tparent $composite_track"
			echo -e "\tcontainer multiWig"			
			echo -e "\tshortLabel $sample_name"
			echo -e "\tlongLabel $sample_name ($s) RPM profile"
			echo -e "\ttype bigWig"
			echo -e "\tvisibility full"
    	    echo -e "\tautoscale off"
	        echo -e "\talwaysZero on"
        	echo -e "\tviewLimits -1.0:1.0"
  	      	echo -e "\taggregate transparentOverlay"
  	      	echo -e "\tshowSubtrackColorOnUi on"
  	      	echo -e "\tmaxHeightPixels 100:50:10"
  	    	echo -e "\tcolor 0,128,0"
   		    echo -e "\tpriority 5"
   		    echo

			echo -e "\t\ttrack ${s}_profile_strand1"
			echo -e "\t\tparent ${s}_profile"
			echo -e "\t\tbigDataUrl ../../$data_type/samples/$s/$track_type/$version/$sequencing_type/${s}_unique_multiple_strand1_rpm.bw"
			echo -e "\t\ttype bigWig"
  	    	echo -e "\t\tcolor 0,128,0"
  	    	echo

			echo -e "\t\ttrack ${s}_profile_strand2"
			echo -e "\t\tparent ${s}_profile"
			echo -e "\t\tbigDataUrl ../../$data_type/samples/$s/$track_type/$version/$sequencing_type/${s}_unique_multiple_strand2_rpm.bw"
			echo -e "\t\ttype bigWig"
			echo -e "\t\tnegateValues on"
  	    	echo -e "\t\tcolor 0,128,0"

			echo

		fi

	fi

done