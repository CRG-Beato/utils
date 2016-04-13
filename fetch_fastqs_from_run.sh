#!/bin/bash


#==================================================================================================
# Created on: 2016-02-08
# Usage: ./fetch_fastqs_from_run.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: copy FASTQ files from the 4DGenome workstation to the CRG cluster
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables 
run_id=160409_NS500645_0048_AHCFNFAFXX_RUN45MM3
release_date=2016-04-09
scp=`which scp`
project=4DGenome
data_type=''

# paths
IDIR=four-d@172.17.133.110:/home/four-d/Desktop/$run_id/Data/Intensities/BaseCalls
if [[ $project == "4DGenome" ]]; then
	ODIR=/users/project/4DGenome/sequencing/$release_date
else
	ODIR=/users/GR/mb/jquilez/data/$data_type/raw/$release_date
fi
mkdir -p $ODIR


#==================================================================================================
# COMMANDS
#==================================================================================================

$scp -v $IDIR/*fastq.gz $ODIR
rm -f $ODIR/Undetermined*
