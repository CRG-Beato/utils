#!/bin/bash


#==================================================================================================
# Created on: 2015-11-18
# Usage: ./batch_download_ucsc_pdfs.sh <regions.bed> <OUTPUT_DIR>
# Author: Javier Quilez (GitHub: jaquol)
# Goal: identify ChIP-seq peaks using MACS2
# I made this script available from *everywhere* by adding the following commands to my '.bashrc'
#==================================================================================================


#=================== (REVIEW before running script!) ==============================================

# UCSC Genome Browser's European mirror
baseurl="http://genome-euro.ucsc.edu/"		
# UCSC session
hgsid=210995862								
hubid=uBD3AsJib3actbt4Ru11sXeZ1lms

#==================================================================================================


# Check input arguments
if [ $# -eq 0 ]; then
	echo -e "\nUsage: ./batch_download_ucsc_pdfs.sh <regions.bed> <OUTPUT_DIR>\n"
	exit
fi
regions=$1
OUTDIR=$2

cat $regions | while read chr beg end; do

	position=$chr":"$beg"-"$end;
	# Output file
	pdf_fname=$OUTDIR/"ucsc_download_"$chr"_"$beg"_"$end".pdf";
	# Link to PDF download, i.e. View > PDF/PS
	s=$baseurl"cgi-bin/hgTracks?hgsid="$hgsid"_"$hubid"&hgt.psOutput=on&position=$position"
	wget $s -O XXX
	s2=`grep 'hgt_genome.*.pdf' XXX | sed 's/.*hgt_genome/hgt_genome/' | sed 's/[.]pdf.*/.pdf/'`
	echo $2
	tgt=$baseurl"/trash/hgt/"$s2
	wget $tgt -O $pdf_fname
	rm XXX

done





