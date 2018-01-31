#!/bin/bash


#==================================================================================================
# Created on: 2017-06-01
# Usage: ./update_public_docs_and_github.sh <project> <analysis> <tag>
# Author: Javier Quilez (GitHub: jaquol)
# Goals: 
# (i) copy project-specific analyses from their original directory to the one which is visible
# from the public-docs website http://public-docs.crg.es/mbeato/jquilez/ 
# ipy_hide_input is used to remove the code from the *.slides.html report
# source: http://hannes-brt.github.io/blog/2013/08/11/ipython-slideshows-will-change-the-way-you-work/
# (ii) git add, commit and push analysis to GitHub
#==================================================================================================


#==================================================================================================
# CONFIGURATION VARIABLES AND PATHS
#==================================================================================================

# variables
project=$1
analysis=$2
tag=$3

# paths
PROJECTS=/users/mbeato/projects/projects
FILE_TRANSFER=/users/mbeato/public-docs
ipy_hide_input=/users/mbeato/projects/utils/ipy_hide_input



#==================================================================================================
# COMMANDS
#==================================================================================================


update_public_docs() {

	p=$1
	a=$2
	echo "... updating https://public_docs.crg.es/mbeato/public-docs/projects/$p/$a"

	# make output directories
	ODIR=$FILE_TRANSFER/projects/$p/$a
	rm -fr $ODIR
	mkdir -p $ODIR

	# copy analysis directories to output directory
	ANALYSIS=$PROJECTS/$p/analysis/$a
	for d in `ls $ANALYSIS |grep -v data`; do
		cp -r $ANALYSIS/$d $ODIR
	done

	# copy project notebook to output directory
	if [ -e $PROJECTS/$p/project_notebook* ]; then
		cp -fr $PROJECTS/$p/project_notebook* $FILE_TRANSFER/projects/$p/
	fi

	# convert ipython notebook to html
	cd $ODIR
	for i in `ls *ipynb`; do
		jupyter nbconvert --to slides *ipynb
		$ipy_hide_input $analysis.slides.html
	done

}

update_github_repo() {

	p=$1
	a=$2
	t=$3

	echo "... updating https://github.com/CRG-Beato/projects/$p/$a"

	cd $PROJECTS
	git add --all $p/analysis/$a
	git commit -m "$t"
	git push

}


update_public_docs $project $analysis
update_github_repo $project $analysis "$tag"
