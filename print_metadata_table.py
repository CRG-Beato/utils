#!/usr/bin/python


#==================================================================================================
# Created on: 2016-03-04
# Usage: python print_metadata_table.py <table> <sample_id> <attribute>
# Author: javier.quilez@crg.eu
# Goal: prints table from the metadata; if a sample_id (unique identifier) and an attribute are
# provided, it print only the specific value for that sample and attribute
#==================================================================================================


# Import python modules and functions
import os, sys
import dataset
import pandas as pd 

# paths and variables
metadata = '/users/GR/mb/jquilez/data/beato_lab_metadata.db'
tab_name = sys.argv[1]
sample_id = sys.argv[2]
attribute = sys.argv[3]

# Load database and table
db = dataset.connect('sqlite:///%s' % metadata)
tab = db.load_table(tab_name)

# export and read in as pandas dataframe
dataset.freeze(tab.all(), format = 'csv', filename = 'tmp.txt')
df = pd.read_csv('tmp.txt')

if sample_id == 'all' and attribute == 'all':
	print df
else:
	print list(df[df['SAMPLE_ID'] == sample_id][attribute])[0]

# remove tmp file 
os.remove('tmp.txt')