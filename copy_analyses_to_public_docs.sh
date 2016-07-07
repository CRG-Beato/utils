#!/bin/bash


#==================================================================================================
# Created on: 2016-01-28
# Usage: ./copy_analyses_to_public_docs.sh <project> <analysis>
# Author: Javier Quilez (GitHub: jaquol)
# Goal: copy project-specific analyses from their original directory to the one which is visible
# from the public-docs website http://public-docs.crg.es/mbeato/jquilez/ 
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
project=$1
analysis=$2

# paths
PROJECTS=$HOME/projects
FILE_TRANSFER=$HOME/file_transfer



#==================================================================================================
# COMMANDS
#==================================================================================================


copy_directory() {

	p=$1
	a=$2
	echo -e "... uploading analyses for the $p project to http://public-docs.crg.es/mbeato/jquilez/"

	# make output directories
	ODIR=$FILE_TRANSFER/projects/$p/$a
	rm -fr $ODIR
	mkdir -p $ODIR

	# copy analysis directories to output directory
	ANALYSIS=$PROJECTS/$p/analysis/$a
	for d in `ls $ANALYSIS |grep -v data`; do
		cp -r $ANALYSIS/$d $ODIR
	done
	#cp -fr $PROJECTS/$p/analysis/$a/* $ODIR/

	# copy project notebook to output directory
	if [ -e $PROJECTS/$p/project_notebook* ]; then
		cp -fr $PROJECTS/$p/project_notebook* $FILE_TRANSFER/projects/$p/
	fi

	# convert ipython notebook to html
	cd $ODIR
	for i in `ls *ipynb`; do
	#for d in `ls $ODIR | grep -v project_notebook`; do
	#	echo $d
	#	cd $ODIR/$d
	#	if [ -e *ipynb ]; then
			#ls *ipynb
			#rm *slides.html
			#ls *slides.html
		ipython nbconvert --to slides *ipynb
	#	fi
	#	cd 		 
	done

}


if [[ $project == "all" ]]; then
	for p in `ls $PROJECTS`; do
		copy_directory $p
	done
else
	copy_directory $project $analysis
fi 
