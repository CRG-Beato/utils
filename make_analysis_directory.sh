#!/bin/bash


#==================================================================================================
# Created on: 2016-02-26
# Usage: ./make_analysis_directory.sh
# Author: javier.quilez@crg.eu
# Goal: makes directory for analysis within the project directory
#==================================================================================================


# variables
project=$1
analysis=$2

# check variables are passed as script parameters
if [ -n "$project" ] && [ -n "$analysis" ]; then
	my_date=`date +"%Y-%m-%d"`
	directory_name=${my_date}_${analysis}
else
	echo -e "\nusage: make_analysis_directory.sh <project> <analysis>\n"
	exit
fi

# make directories and files
if [[ $project == "4DGenome" ]]; then
	ANALYSIS=/users/project/4DGenome/analysis/$directory_name
	mkdir -p $ANALYSIS/{scripts,tables,figures,data}
	md=$ANALYSIS/$directory_name.md
	ipynb=$ANALYSIS/$directory/$directory_name.ipynb
	rm -f $md
	rm -f $ipynb
	echo "# Introduction" >> $md
	echo " " >> $md
	echo -e "\n**paths are relative to /users/projects/4DGenome**\n\n" >> $md
	notedown $md > $ipynb
	rm -f $md
else
	ANALYSIS=/users/mbeato/projects/projects/$project/analysis/${my_date}_${analysis}
	mkdir -p $ANALYSIS/{scripts,tables,figures,data}
	md=$ANALYSIS/$directory_name.md
	ipynb=$ANALYSIS/$directory_name.ipynb
	rm -f $md
	rm -f $ipynb
	echo "# Introduction" >> $md
	echo " " >> $md
	echo -e "\n**paths are relative to /users/mbeato/projects**\n\n" >> $md
	notedown $md > $ipynb
	rm -f $md
fi

echo -e "\nanalysis directory created at $ANALYSIS\n"
