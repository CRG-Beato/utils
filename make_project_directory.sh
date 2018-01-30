#!/bin/bash


#==================================================================================================
# Created on: 2016-03-01
# Usage: ./make_project_directory.sh
# Author: javier.quilez@crg.eu
# Goal: makes project directory
#==================================================================================================


# variables
project=$1

# check variables are passed as script parameters
if [ -n "$project" ]; then
	PROJECT=/users/mbeato/projects/projects/$project
	if [ ! -d $PROJECT ]; then
		# make directories
		mkdir -p $PROJECT/{data,analysis}
		# make project notebook
		md=$PROJECT/README.md
		rm -f $md
		echo "# $project" >> $md
		echo -e "\n**objective: ...**" >> $md
		echo -e "\n**paths are relative to /users/mbeato/projects**\n\n" >> $md
		echo -e "\nproject directory created at $PROJECT\n"
		echo "## Project directory stucture" >> $md
		echo >> $md
		echo "- analysis: subdirectories for the different analyses, named as <date_of_analysis>_<analysis_name>" >> $md
		echo "- data: input data that are not sample-specific (which are are at /users/mbeato/projects/)" >> $md
		echo "- project_notebook_<project_name>.md: this file..." >> $md
		echo >> $md
		echo >> $md
	else
		echo -e "\n$PROJECT already exists\n"
		exit
	fi
else
	echo -e "\nusage: make_analysis_directory.sh <project>\n"
	exit
fi
