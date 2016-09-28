#!/bin/bash


#==================================================================================================
# Created on: 2016-09-27
# Usage: ./make_fastq_subsamples.sh
# Author: Javier Quilez (GitHub: jaquol)
# Goal: for each sample FASTQ subsample N random reads, where can take different values
#==================================================================================================

# so far only for single-end data


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
samples="gv_066_01_01_chipseq"
process=make_fastq_subsamples
project=misc
data_type=chipseq
analysis=2016-09-27_impact_sequencing_depth_chipseq_experiments
sequencing_type=SE
min=10000000
step=10000000

# paths
ANALYSIS=$HOME/projects/$project/analysis/$analysis
DATA=$HOME/data/$data_type/raw
JOB_CMD=$ANALYSIS/job_cmd
JOB_OUT=$ANALYSIS/job_out
mkdir -p $JOB_CMD
mkdir -p $JOB_OUT
seqtk=`which seqtk`
pigz=`which pigz`

# Cluster parameters
queue=long-sl65
memory=80G
max_time=24:00:00
slots=1


#==================================================================================================
# COMMANDS
#==================================================================================================

for s in $samples; do

	# output directory
	ODIR=$ANALYSIS/data/fastqs/$s
	mkdir -p $ODIR

	# table with the correspondance between the sample ID and the FASTQ name
	otab=$ODIR/sample_to_fastqs.txt
	rm -fr $otab

	echo "* sample = $s"
	# find FASTQ file
	ifq=$DATA/*/$s*.fastq.gz

	# calculate the number of reads
	n_lines=`$pigz -dc $ifq |wc -l`
	n_sequenced_reads=`echo $n_lines / 4 |bc`
	echo "* number of sequenced reads = $n_sequenced_reads"

	# make subsamples of increasing sizes
	echo "* making subsamples of increasing sizes"
	my_range=`seq $min $step $n_sequenced_reads`
	my_range="1000000 $my_range"
	for n in $my_range; do

		# Build job: parameters
		job_name=${process}_${s}_${n}
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
		sed -i 's/^\t\t//g' $job_file

		# seqtk commands
		# -s 100 sets the random seed, for reproducibility purposes
		ofq=$ODIR/${s}_${n}reads.fastq
		job_cmd="$seqtk sample -s 100 $ifq $n > $ofq; gzip -f $ofq"
		echo $job_cmd >> $job_file

		# add to table
		echo -e "${s}_${n}reads\t${s}_${n}reads.fastq.gz" >> $otab

		# Submit job
		chmod a+x $job_file
		#qsub < $job_file
		#$job_file

	done 

done