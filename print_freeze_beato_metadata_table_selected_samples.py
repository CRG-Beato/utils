#!/usr/bin/python


#==================================================================================================
# Created on: 2016-04-21
# Usage: ./print_freeze_beato_metadata_table_selected_samples.py
# Author: Javier Quilez (GitHub: jaquol)
# Goal: saves in a file metadata values for a selected table and group of samples
#==================================================================================================


import os
import dataset
import time
import pandas as pd

# variables
samples="fd_037_01_01_chipseq fd_038_01_01_chipseq fd_039_01_01_chipseq fd_040_01_01_chipseq fd_041_01_01_chipseq fd_042_01_01_chipseq fd_043_01_01_chipseq fd_044_01_01_chipseq"
project = 'fledily'
analysis = '2019-01-08_chipseq__unit'
table = 'quality_control_raw_reads'

# connect to database
ifile = '/users/mbeato/projects/data/beato_lab_metadata.db'
db = dataset.connect("sqlite:///%s" % ifile)

# paths
ODIR = '/users/mbeato/projects/projects/%s/analysis/%s' % (project, analysis)

# print table
ttab = '%s/tables/tmp_%s.csv' % (ODIR, table)
result = db[table].all()
dataset.freeze(result, format = 'csv', filename = ttab)

# re-import table and filter rows corresponding to the selected samples
df = pd.read_table(ttab, sep = ',')
samples_list = samples.split(' ')
otab = '%s/tables/%s.txt' % (ODIR, table)
df[df['SAMPLE_ID'].isin(samples_list)].sort(['SAMPLE_ID']).to_csv(otab, sep = "\t", index = False)

# remove intermediate file
os.remove(ttab)
