#!/usr/bin/python



#==================================================================================================
# Created on: 2016-05-18
# Usage: ./my_python_utils.py
# Author: javier.quilez@crg.eu
# Goal: stuff I use very often in python
#==================================================================================================


def print_narrowpeak_header():

	# defined as in: https://genome.ucsc.edu/FAQ/FAQformat.html#format12
	h = ['chrom', 'chromStart', 'chromEnd', 'name', 'score', 'strand', 'signalValue', 'pValue', 'qValue', 'peak']

	return h