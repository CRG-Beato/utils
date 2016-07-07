#!/bin/bash


#==================================================================================================
# Created on: 2016-04-08
# Usage: ./combine_fastqs.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: bcl2fastq conversion produces, for each sample, as many FASTQs as lanes, so we need to
# combine them to have one FASTQ per sample
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="LDC_1 LDC_2 LDC_3"
process=combine_fastqs
project=4DGenome
release_date=2016-06-28
data_type='hic'
analysis=2016-06-29_run_hic-16.05_sequencing_2016-06-28_unit
sequencing_type="PE"

# paths
if [[ $project == "4DGenome" ]]; then
	IODIR=/users/project/4DGenome/sequencing/$release_date
	ANALYSIS=/users/project/4DGenome/analysis/$analysis
else
	IODIR=/users/GR/mb/jquilez/data/$data_type/raw/$release_date
	ANALYSIS=/users/GR/mb/jquilez/projects/$project/analysis/$analysis	
fi
JOB_CMD=$ANALYSIS/job_cmd
JOB_OUT=$ANALYSIS/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT

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

	# Submit job
	chmod a+x $job_file
	qsub < $job_file

done


