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
samples="rf_013_01_02_rnaseq rf_014_01_02_rnaseq rf_015_01_02_rnaseq rf_016_01_02_rnaseq rf_017_01_02_rnaseq rf_018_01_02_rnaseq rf_019_01_02_rnaseq rf_020_01_02_rnaseq rf_021_01_02_rnaseq rf_022_01_02_rnaseq rf_023_01_02_rnaseq rf_024_01_02_rnaseq rf_025_01_02_rnaseq"
project = 'rferrari'
analysis = '2016-06-01_run_rnaseq-16.04_sequencing_2016-05-30_4dgu'
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
