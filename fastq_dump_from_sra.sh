#!/bin/bash


#==================================================================================================
# Created on: 2018-05-24
# Usage: ./fastq_dump_from_sra.sh
# Author: JL Villanueva Cañas (GitHub: egenomics)
# Goal: downloads FASTQ files from SRA (using one or several SRR code per sample) and convert into the desired sample id
#==================================================================================================



#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
analysis=2018-10-23_hic_2018-10-23_external
download_date=2018-10-23
process=fastq_dump_from_sra
project='4DGenome'
data_type='hic'
table_name=sample_id_to_srr.txt
email=joseluis.villanueva@crg.eu

# paths
if [[ $project == '4DGenome' ]]; then
	PROJECT=/users/project/4DGenome
	ODIR=$PROJECT/sequencing/$download_date
else
	PROJECT=/users/mbeato/projects/projects/$project
	ODIR=/users/mbeato/projects/data/$data_type/raw/$download_date
fi
mkdir -p $ODIR
ANALYSIS=$PROJECT/analysis/$analysis
JOB_CMD=$ANALYSIS/job_cmd
JOB_OUT=$ANALYSIS/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
itab=$PROJECT/analysis/$analysis/tables/$table_name
fastq_dump=`which fastq-dump`
prefetch=`which prefetch`
vdbvalidate=`which vdb-validate`
# Cluster parameters
queue=long-sl7
memory=2G
max_time=48:00:00
slots=1


#==================================================================================================
# COMMANDS
#==================================================================================================

while IFS=$'\t' read -r -a line; do
# get HIC and SRR codes
sample_name=${line[0]}
srrs=$(echo ${line[1]} | sed 's/,/ /g');
#read array containing SRR
	run_num=0
#split_srr_array and create a job for each srr
	for srr in $srrs; do
		let "run_num++"
		# Build job: parameters
		job_name=${process}_${sample_name}_${srr}
		job_file=$JOB_CMD/$job_name.sh
		rm $job_file
		m_out=$JOB_OUT
		echo "#!/bin/bash
		#$ -N $job_name
		#$ -q $queue
		#$ -l virtual_free=$memory
		#$ -l h_rt=$max_time
		#$ -o $m_out/${job_name}_\$JOB_ID.out
		#$ -e $m_out/${job_name}_\$JOB_ID.err
		#$ -j y
		#$ -M $email
		#$ -m abe
		#$ -pe smp $slots" > $job_file
		sed -i 's/^\t//g' $job_file

		# download FASTQ and rename
		job_cmd="$prefetch --max-size 50000000 $srr && $vdbvalidate $srr && $fastq_dump $srr --split-files -O $ODIR -DQ '+' --gzip"
		echo $job_cmd >> $job_file
		job_cmd="mv $ODIR/${srr}_1.fastq.gz $ODIR/${sample_name}_read1.fastq.gz_${run_num}"
		echo $job_cmd >> $job_file
		job_cmd="mv $ODIR/${srr}_2.fastq.gz $ODIR/${sample_name}_read2.fastq.gz_${run_num}"
		echo $job_cmd >> $job_file

		# Submit job
		chmod a+x $job_file
		qsub < $job_file
		sleep 0.1
		#cat $job_file
	done
done <$itab
