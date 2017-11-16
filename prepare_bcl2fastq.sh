#!/bin/bash


#==================================================================================================
# Created on: 2017-11-16
# Usage: ./prepare_bcl2fastq.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: prepares the SampleSheet.csv file required by bcl2fastq
#==================================================================================================




#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="064cf0f28_be2f5f693 CAR_22 CAR_23 CAR_24 dc3a1e069_be2f5f693 fc3e8b36a_8654297db fc3e8b36a_ba68d4402 FPR_17 FPR_18 FPR_23_1 FPR_23_2 rf_090_01_01_chipseq yc_022_01_01_chipseq"
run_id=171020_NS500645_0119_AHKMFMBGX3_RUN114_4DG6
project=4DGenome

# paths
if [[ $project == "4DGenome" ]]; then
	UTILS=/users/project/4DGenome/utils
else
	UTILS=$HOME/utils
fi
io_metadata=$UTILS/io_metadata.sh
ofile=SampleSheet.csv



#==================================================================================================
# COMMANDS
#==================================================================================================

# header
echo '[Data]' > $ofile
echo 'Lane,Sample_ID,Sample_Name,index,index2,' >> $ofile

# add content
i=0
for s in $samples; do

	# get index
	index=`$io_metadata -m get_from_metadata -s $s -t input_metadata -a SEQUENCING_INDEX`

	# get numeric sample name required by bcl2fastq
	i=`expr $i + 1`
	
	# make an entry for each of the 4 lanes of the NextGen sequencer
	for j in `seq 4`; do

		echo "$j,$i,$s,$index," >> $ofile

	done

done

# copy to the corresponding run directory in the 4DGenome workstation
ODIR=four-d@172.17.133.110:/home/four-d/Desktop
scp -v $ofile $ODIR/${run_id}_SampleSheet.csv

rm -f $ofile

