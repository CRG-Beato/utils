#!/bin/bash


#==================================================================================================
# Created on: 2016-02-02
# Usage: ./fastq_dump_from_sra.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: downloads FASTQ files from SRA (using SRR code) and convert into the desired sample id
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
analysis=2016-06-27_run_hic-16.05_rao_samples_evidal
download_date=2016-09-07
process=fastq_dump_from_sra
project='4DGenome'
data_type='hic'
table_name=sample_id_to_srr_batch_2016_09_07.txt

# paths
if [[ $project == '4DGenome' ]]; then
	PROJECT=/users/project/4DGenome
	ODIR=$PROJECT/sequencing/$download_date
else
	PROJECT=/users/GR/mb/jquilez/projects/$project
	ODIR=/users/GR/mb/jquilez/data/$data_type/raw/$download_date
fi
mkdir -p $ODIR
ANALYSIS=$PROJECT/analysis/$analysis
JOB_CMD=$ANALYSIS/job_cmd
JOB_OUT=$ANALYSIS/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
itab=$PROJECT/analysis/$analysis/tables/$table_name

# Cluster parameters
queue=long-sl65
memory=2G
max_time=48:00:00
slots=1 	



#==================================================================================================
# COMMANDS
#==================================================================================================

while read line; do

	# get HIC and SRR codes
	sample_name=`echo $line | awk '{print $1}'`
	srr=`echo $line | awk '{print $2}'`

	# Build job: parameters
	job_name=${process}_${sample_name}_${srr}
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

	# download FASTQ and rename
	job_cmd="fastq-dump $srr --split-files -O $ODIR -DQ '+' --gzip"
	echo $job_cmd >> $job_file
	job_cmd="mv $ODIR/${srr}_1.fastq.gz $ODIR/${sample_name}_read1.fastq.gz"
	echo $job_cmd >> $job_file
	job_cmd="mv $ODIR/${srr}_2.fastq.gz $ODIR/${sample_name}_read2.fastq.gz"
	echo $job_cmd >> $job_file

	# Submit job
	chmod a+x $job_file
	qsub < $job_file
	sleep 10

done <$itab