#!/bin/bash


#==================================================================================================
# Created on: 2016-02-08
# Usage: ./combine_fastqs_and_quality_control.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: 1. bcl2fastq conversion produces, for each sample, as many FASTQs as lanes, so we need to
# combine them to have one FASTQ per sample
# 2. perform quality control of raw reads before mapping using FastQC
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="cbf5146d5_ac9f54f0a 9cecf0755_ac9f54f0a 248b851a9_ac9f54f0a ddee6ba41_ac9f54f0a 8276ee842_ac9f54f0a 01acaf84f_ac9f54f0a 752cd3e86_ac9f54f0a 4369ff754_ac9f54f0a 286589cb2_ac9f54f0a"
process=combine_fastqs_and_quality_control
project=4DGenome
release_date=2016-01-28
data_type=''
analysis=2016-02-09_get_and_quality_control_fastqs_Francois_LeDily
sequencing_type="PE"

# paths
if [[ $project == "4DGenome" ]]; then
	IODIR=/users/project/4DGenome/sequencing/$release_date
	ANALYSIS=/users/project/4DGenome/analysis/$analysis
else
	IODIR=/users/mbeato/projects/data/$data_type/raw/$release_date
	ANALYSIS=/users/mbeato/projects/projects/$project/analysis/$analysis	
fi
FASTQC=$IODIR/fastqc
JOB_CMD=$ANALYSIS/job_cmd
JOB_OUT=$ANALYSIS/job_out
mkdir -p $FASTQC
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
fastqc=/users/mbeato/projects/software/FastQC/fastqc
unzip=`which unzip`

# Cluster parameters
queue=short-sl65
memory=10G
max_time=06:00:00
slots=1


#==================================================================================================
# COMMANDS
#==================================================================================================

for s in $samples; do

	# Build job: parameters
	job_name=${process}_${s}
	job_file=$JOB_CMD/$job_name.sh
	m_out=$JOB_OUT
	echo "#!/bin/bash
	#$ -N $job_name
	#$ -q $queue
	#$ -l virtual_free=$memory
	#$ -l h_rt=$max_time
	#$ -o $m_out/${job_name}_\$JOB_ID.out
	#$ -e $m_out/${job_name}_\$JOB_ID.err
	#$ -j y
	#$ -M javier.quilez@crg.eu
	#$ -m abe
	#$ -pe smp $slots" > $job_file
	sed -i 's/^\t//g' $job_file

	# combine the multiple FASTQ files per sample (1 for each lane) into a single sample FASTQ
	old_s=`echo $s | sed "s/_/-/g"`
	job_cmd="cat `ls $IODIR/$old_s*R1*` > $IODIR/${s}_read1.fastq.gz"
	echo $job_cmd >> $job_file
	if [[ $sequencing_type == "PE" ]]; then
		job_cmd="cat `ls $IODIR/$old_s*R2*` > $IODIR/${s}_read2.fastq.gz"
		echo $job_cmd >> $job_file
	fi
	echo "rm -fr $IODIR/$old_s*" >> $job_file

	# FastQC
	job_cmd="$fastqc $IODIR/${s}_read1.fastq.gz -o $FASTQC; $unzip $FASTQC/${s}_read1_fastqc -d $FASTQC; rm -f $FASTQC/${s}_read1_fastqc.zip"
	echo $job_cmd >> $job_file
	if [[ $sequencing_type == "PE" ]]; then
		job_cmd="$fastqc $IODIR/${s}_read2.fastq.gz -o $FASTQC; $unzip $FASTQC/${s}_read2_fastqc -d $FASTQC; rm -f $FASTQC/${s}_read2_fastqc.zip"
		echo $job_cmd >> $job_file
	fi

	# Submit job
	chmod a+x $job_file
	qsub < $job_file

done


